import 'dart:async';
import 'dart:io';
import 'package:door_to_door_service/core/utils/log_util.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';

/// 定位服务 - 全局单例（由 GetX 管理）
class LocationService extends GetxService {
  final String _tag = 'LocationService';
  final bool isDebug = false; // 是否启用调试日志

  // 百度定位插件实例
  final LocationFlutterPlugin _locationPlugin = LocationFlutterPlugin();

  // 响应式状态
  final Rx<BaiduLocation?> _currentLocation = Rx<BaiduLocation?>(null);
  final RxBool _isLocating = false.obs;
  final RxBool _isAuthorized = false.obs;

  // 存储键
  static const String _keyLatitude = 'latitude';
  static const String _keyLongitude = 'longitude';
  static const String _keyProvince = 'province';
  static const String _keyCity = 'city';
  static const String _keyDistrict = 'district';
  static const String _keyAddress = 'address';
  static const String _keyLocationPermissionRequested =
      'location_permission_requested';

  // 外部回调
  Function(double latitude, double longitude)? onLocationUpdated;

  // Getters
  BaiduLocation? get currentLocation => _currentLocation.value;
  bool get isLocating => _isLocating.value;
  bool get isAuthorized => _isAuthorized.value;
  String? get currentCity => _currentLocation.value?.city;
  String? get currentProvince => _currentLocation.value?.province;
  String? get currentDistrict => _currentLocation.value?.district;
  String? get currentAddress => _currentLocation.value?.address;
  double? get longitude => _currentLocation.value?.longitude;
  double? get latitude => _currentLocation.value?.latitude;

  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      if (isDebug) {
        LogUtil.d('正在初始化定位服务...', tag: _tag);
      }
      _setupPrivacy();
      if (Platform.isIOS) _setIOSAK();
      if (Platform.isAndroid) {
        BMFMapSDK.setCoordType(BMF_COORD_TYPE.BD09LL);
      }
      await _loadLastLocation(); // 先加载缓存，首屏立即显示本地城市
      _requestPermissionAndStart();
      if (isDebug) {
        LogUtil.d('定位服务初始化完成', tag: _tag);
      }
    } catch (e) {
      if (isDebug) {
        LogUtil.e('定位服务初始化失败: $e', tag: _tag);
      }
    }
  }

  /// 设置百度 SDK 隐私政策
  Future<void> _setupPrivacy() async {
    BMFMapSDK.setAgreePrivacy(true); // 同意隐私政策
    _locationPlugin.setAgreePrivacy(true);
    if (isDebug) {
      LogUtil.d('已同意百度隐私政策', tag: _tag);
    }
  }

  /// iOS 设置 AK
  Future<void> _setIOSAK() async {
    BMFMapSDK.setApiKeyAndCoordType(
        'r5WLi2wuL2j8LfHDwFDOmtpRoBWw66mV', BMF_COORD_TYPE.BD09LL);
    _locationPlugin.authAK('r5WLi2wuL2j8LfHDwFDOmtpRoBWw66mV'); // 替换为实际 AK
    if (isDebug) {
      LogUtil.d('已设置 iOS AK', tag: _tag);
    }
  }

  /// 请求权限并启动定位（若权限通过）
  Future<void> _requestPermissionAndStart() async {
    final granted = await requestPermission();
    _isAuthorized.value = granted;
    if (!granted) {
      if (isDebug) {
        LogUtil.w('定位权限未授予，无法启动定位', tag: _tag);
      }
      return;
    }
    // 设置持续定位回调（但不自动开始，由外部调用 startContinuousLocation）
    _setupContinuousCallback();
    // 可选：自动开始一次单次定位获取初始位置
    await getLocationOnce();
  }

  /// 请求定位权限（处理首次拒绝和永久拒绝）
  Future<bool> requestPermission() async {
    final status = await Permission.location.status;
    if (isDebug) {
      LogUtil.d('当前定位权限状态: $status', tag: _tag);
    }
    if (status.isGranted) return true;

    if (status.isDenied) {
      final prefs = await SharedPreferences.getInstance();
      final hasRequested =
          prefs.getBool(_keyLocationPermissionRequested) ?? false;
      if (hasRequested) {
        if (isDebug) {
          LogUtil.w('定位权限被拒绝，请前往设置开启', tag: _tag);
        }
        return false;
      }
      final result = await Permission.location.request();
      await prefs.setBool(_keyLocationPermissionRequested, true);
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      if (isDebug) {
        LogUtil.w('定位权限永久被拒绝，请前往设置开启', tag: _tag);
      }
      // 可在此处引导用户去设置页面
      return false;
    }

    return false;
  }

  /// 设置持续定位回调（不自动开始定位）
  void _setupContinuousCallback() {
    _locationPlugin.seriesLocationCallback(
      callback: (BaiduLocation result) {
        LogUtil.d('持续定位结果: $result', tag: _tag);
        _currentLocation.value = result;
        _saveLocation(result);
        _updateCityFromLocation(result);
        _notifyLocationUpdated(result);
      },
    );
    if (isDebug) {
      LogUtil.d('已设置持续定位回调', tag: _tag);
    }
  }

  /// 开始持续定位
  Future<void> startContinuousLocation() async {
    if (!_isAuthorized.value) {
      if (isDebug) {
        LogUtil.w('未授权，无法启动持续定位', tag: _tag);
      }
      return;
    }
    await _setLocationOptions(isContinuous: true);
    await _locationPlugin.startLocation();
    _isLocating.value = true;
    if (isDebug) {
      LogUtil.d('持续定位已启动', tag: _tag);
    }
  }

  /// 停止持续定位
  Future<void> stopContinuousLocation() async {
    await _locationPlugin.stopLocation();
    _isLocating.value = false;
    if (isDebug) {
      LogUtil.d('持续定位已停止', tag: _tag);
    }
  }

  /// 单次定位
  Future<BaiduLocation?> getLocationOnce() async {
    if (!_isAuthorized.value) {
      if (isDebug) {
        LogUtil.w('未授权，无法获取位置', tag: _tag);
      }
      return null;
    }
    _isLocating.value = true;
    try {
      await _setLocationOptions(isContinuous: false);
      final completer = Completer<BaiduLocation?>();
      _locationPlugin.singleLocationCallback(
        callback: (BaiduLocation result) {
          if (isDebug) {
            LogUtil.d('单次定位结果: $result', tag: _tag);
          }
          _currentLocation.value = result;
          _saveLocation(result);
          _updateCityFromLocation(result);
          _notifyLocationUpdated(result);
          if (!completer.isCompleted) completer.complete(result);
        },
      );
      if (Platform.isIOS) {
        await _locationPlugin.singleLocation({});
      } else {
        await _locationPlugin
            .startLocation(); // Android 单次也用 startLocation，但 scanspan=0
      }
      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (isDebug) {
            LogUtil.w('单次定位超时', tag: _tag);
          }
          return null;
        },
      );
    } catch (e) {
      if (isDebug) {
        LogUtil.e('获取位置失败: $e', tag: _tag);
      }
      return null;
    } finally {
      _isLocating.value = false;
    }
  }

  /// 统一设置定位参数
  Future<void> _setLocationOptions({required bool isContinuous}) async {
    // Android 参数
    final androidOption = BaiduLocationAndroidOption(
      coordType: BMFLocationCoordType.bd09ll,
      locationMode: BMFLocationMode.hightAccuracy,
      isNeedAddress: true,
      isNeedAltitude: true,
      scanspan: isContinuous ? 2000 : 0, // 0 表示单次
    );
    // iOS 参数
    final iosOption = BaiduLocationIOSOption(
      coordType: BMFLocationCoordType.bd09ll,
      desiredAccuracy: BMFDesiredAccuracy.best,
      locationTimeout: 10,
      reGeocodeTimeout: 10,
    );
    await _locationPlugin.prepareLoc(
        androidOption.getMap(), iosOption.getMap());
    if (isDebug) {
      LogUtil.d('已设置定位参数: isContinuous=$isContinuous', tag: _tag);
    }
  }

  /// 保存位置到本地
  Future<void> _saveLocation(BaiduLocation location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyLatitude, location.latitude ?? 0.0);
      await prefs.setDouble(_keyLongitude, location.longitude ?? 0.0);
      await prefs.setString(_keyProvince, location.province ?? '');
      await prefs.setString(_keyCity, location.city ?? '');
      await prefs.setString(_keyDistrict, location.district ?? '');
      await prefs.setString(_keyAddress, location.address ?? '');
    } catch (e) {
      LogUtil.w('保存位置失败: $e', tag: _tag);
    }
  }

  /// 加载上次位置
  Future<void> _loadLastLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_keyLatitude);
      final lng = prefs.getDouble(_keyLongitude);
      if (lat != null && lng != null) {
        _currentLocation.value = BaiduLocation(
          latitude: lat,
          longitude: lng,
          province: prefs.getString(_keyProvince),
          city: prefs.getString(_keyCity),
          district: prefs.getString(_keyDistrict),
          address: prefs.getString(_keyAddress),
        );
        if (isDebug) {
          LogUtil.d('加载上次位置成功: ${_currentLocation.value}', tag: _tag);
        }
      }
    } catch (e) {
      if (isDebug) {
        LogUtil.w('加载上次位置失败: $e', tag: _tag);
      }
    }
  }

  /// 清除本地存储的位置
  Future<void> clearLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyLatitude);
      await prefs.remove(_keyLongitude);
      await prefs.remove(_keyProvince);
      await prefs.remove(_keyCity);
      await prefs.remove(_keyDistrict);
      await prefs.remove(_keyAddress);
      _currentLocation.value = null;
    } catch (e) {
      // ignore
    }
  }

  /// 从定位结果更新城市信息
  Future<void> _updateCityFromLocation(BaiduLocation location) async {
    if (location.province == null || location.city == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('location_city', location.city!);
      await prefs.setString('location_province', location.province!);
      if (location.district != null) {
        await prefs.setString('location_district', location.district!);
      }
      if (location.cityCode != null) {
        await prefs.setString('location_city_code', location.cityCode!);
      }
      if (isDebug) {
        LogUtil.d('已更新城市信息: ${location.city}', tag: _tag);
      }
    } catch (e) {
      if (isDebug) {
        LogUtil.w('更新城市信息失败: $e', tag: _tag);
      }
    }
  }

  /// 通知外部位置更新
  void _notifyLocationUpdated(BaiduLocation location) {
    if (location.latitude != null && location.longitude != null) {
      onLocationUpdated?.call(location.latitude!, location.longitude!);
    }
  }

  @override
  void onClose() {
    _locationPlugin.stopLocation();
    // 可移除回调（若 SDK 支持）
    super.onClose();
  }
}
