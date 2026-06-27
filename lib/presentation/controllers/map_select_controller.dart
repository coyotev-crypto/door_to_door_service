import 'package:dtd/core/themes/resource.dart';
import 'package:dtd/core/utils/log_util.dart';
import 'package:dtd/core/utils/toast_util.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dtd/core/services/location_service.dart';
import 'package:dtd/data/models/address_model.dart';

/// 地图选择地址控制器
/// 负责管理地图选择地址页面的状态和业务逻辑
class MapSelectController extends GetxController {
  static const String _tag = 'MapSelectController';

  /// 地图控制器
  BMFMapController? mapController;

  /// 选中的位置坐标
  BMFCoordinate? selectedLocation;

  /// 选中的地址文本
  String selectedAddress = '';

  /// 是否正在加载
  bool isLoading = true;

  /// 地图是否已准备就绪
  bool isMapReady = false;

  /// 当前标记对象，用于移除
  BMFMarker? currentMarker;

  /// 所有标记列表
  List<BMFMarker> markers = [];

  /// 地图类型
  BMFMapType mapType = BMFMapType.Standard;

  /// 定位服务
  LocationService get locationService => Get.find<LocationService>();

  @override
  void onInit() {
    super.onInit();
    initLocationAndMap();
  }

  /// 初始化位置和地图
  Future<void> initLocationAndMap() async {
    final status = await Permission.location.status;
    if (!status.isGranted) {
      final result = await Permission.location.request();
      if (!result.isGranted) {
        isLoading = false;
        ToastUtil.showError('需要定位权限才能使用地图选点功能');
        update();
        return;
      }
    }

    try {
      double? lat = locationService.latitude;
      double? lng = locationService.longitude;
      if (lat == null || lng == null) {
        final location = await locationService.getLocationOnce();
        if (location != null) {
          lat = location.latitude;
          lng = location.longitude;
        }
      }
      final defaultLat = lat ?? 31.239508;
      final defaultLng = lng ?? 121.499718;

      selectedLocation = BMFCoordinate(defaultLat, defaultLng);
      selectedAddress = locationService.currentAddress ?? '当前位置';
      isLoading = false;
      update();
    } catch (e) {
      isLoading = false;
      ToastUtil.showError('获取位置失败: $e');
      update();
    }
  }

  /// 地图创建完成回调
  void onBMFMapCreated(BMFMapController controller) {
    LogUtil.d('地图创建完成，设置回调函数', tag: _tag);
    mapController = controller;
    isMapReady = true;

    // 地图加载回调
    mapController?.setMapDidLoadCallback(callback: () {
      LogUtil.d('地图加载完成', tag: _tag);
      // 地图加载完成后，在当前位置添加marker
      if (selectedLocation != null) {
        addMarker(selectedLocation!);
        LogUtil.d(
            '已在当前位置添加marker: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}',
            tag: _tag);
      }
    });

    // 地图渲染每一帧画面过程中，以及每次需要重绘地图时都会调用此接口
    mapController?.setMapOnDrawMapFrameCallback(
        callback: (BMFMapStatus mapStatus) {
      // 可选：打印地图状态信息
      // print('地图渲染每一帧\n mapStatus = ${mapStatus.toMap()}');
    });

    // 地图区域即将改变时会调用此接口
    mapController?.setMapRegionWillChangeCallback(
        callback: (BMFMapStatus mapStatus) {
      LogUtil.d('地图区域即将改变\n mapStatus = ${mapStatus.toMap()}');
    });

    // 地图区域改变完成后会调用此接口
    mapController?.setMapRegionDidChangeCallback(
        callback: (BMFMapStatus mapStatus) {
      LogUtil.d('地图区域改变完成\n mapStatus = ${mapStatus.toMap()}');
      // 地图移动结束后，更新中心点位置
      onMapRegionChanged(mapStatus);
    });

    // 地图空白区域点击
    mapController?.setMapOnClickedMapBlankCallback(
        callback: (BMFCoordinate point) {
      onMapClicked(point);
    });

    // POI 点击
    mapController?.setMapOnClickedMapPoiCallback(callback: (BMFMapPoi mapPoi) {
      onMapPoiClicked(mapPoi);
    });

    // Marker 点击回调
    mapController?.setMapClickedMarkerCallback(callback: (BMFMarker marker) {
      onMarkerClicked(marker);
    });
  }

  /// 地图空白区域点击回调
  void onMapClicked(BMFCoordinate point) {
    LogUtil.d('地图空白区域被点击，位置: ${point.latitude}, ${point.longitude}', tag: _tag);
    // selectedLocation = point;
    // selectedAddress =
    //     '经度: ${point.longitude.toStringAsFixed(6)}, 纬度: ${point.latitude.toStringAsFixed(6)}';
    // updateMarker(point);
    // update();
  }

  /// POI 点击回调
  void onMapPoiClicked(BMFMapPoi poi) {
    final point = poi.pt;
    selectedLocation = point;
    selectedAddress = poi.text ?? '未知位置';
    updateMarker(point!);
    // 移动地图中心到该 POI
    mapController?.updateMapOptions(BMFMapOptions(center: point));
    update();
  }

  /// Marker 点击回调
  void onMarkerClicked(BMFMarker marker) {
    LogUtil.d('Marker被点击: ${marker.id}, 标题: ${marker.title}', tag: _tag);
    for (BMFMarker m in markers) {
      if (m.id == marker.id) {
        LogUtil.d('更新选中的marker图标: ${m.id}', tag: _tag);
        // 更新选中的marker图标
        m.updateIcon(Resource.mapMarkerIcon);
        selectedAddress = marker.title ?? "";
      } else {
        LogUtil.d('更新未选中的marker图标: ${m.id}', tag: _tag);
        // 更新未选中的marker图标
        m.updateIcon(Resource.mapMarkerIcon);
      }
    }
    update();
  }

  /// 添加标记
  void addMarker(BMFCoordinate point) {
    LogUtil.d(
        'addMarker 被调用，isMapReady: $isMapReady, mapController: ${mapController != null}',
        tag: _tag);
    if (!isMapReady || mapController == null) {
      LogUtil.d('地图未准备好或mapController为空，无法添加marker', tag: _tag);
      return;
    }

    // 创建自定义标记图标
    final marker = BMFMarker.icon(
      position: point,
      identifier: 'selected_marker_${DateTime.now().millisecondsSinceEpoch}',
      title: '选中位置',
      icon: Resource.mapMarkerIcon,
    );

    LogUtil.d(
        '准备添加marker: ${marker.id}, 位置: ${point.latitude}, ${point.longitude}',
        tag: _tag);

    mapController?.addMarker(marker);
    currentMarker = marker; // 保存引用以便后续移除
    markers.add(marker); // 将marker添加到列表中

    LogUtil.d('marker已添加，当前markers数量: ${markers.length}', tag: _tag);
  }

  /// 更新标记（先移除旧标记，再添加新标记）
  void updateMarker(BMFCoordinate point) {
    LogUtil.d(
        'updateMarker 被调用，isMapReady: $isMapReady, mapController: ${mapController != null}',
        tag: _tag);
    if (!isMapReady || mapController == null) {
      LogUtil.d('地图未准备好或mapController为空，无法更新marker', tag: _tag);
      return;
    }

    // 移除旧标记
    if (currentMarker != null) {
      LogUtil.d('移除旧marker: ${currentMarker!.id}', tag: _tag);
      mapController?.removeMarker(currentMarker!);
      markers.remove(currentMarker!); // 从列表中移除
      currentMarker = null;
    }

    // 添加新标记
    LogUtil.d('准备添加新marker，位置: ${point.latitude}, ${point.longitude}',
        tag: _tag);
    addMarker(point);
  }

  /// 切换地图类型
  void changeMapType(BMFMapType type) {
    mapType = type;
    mapController?.updateMapOptions(BMFMapOptions(mapType: type));
    update();
  }

  /// 地图区域变化回调
  void onMapRegionChanged(BMFMapStatus mapStatus) {
    LogUtil.d('地图区域变化回调被调用', tag: _tag);
    if (mapStatus.targetGeoPt != null) {
      LogUtil.d(
          '地图中心点改变: ${mapStatus.targetGeoPt!.latitude}, ${mapStatus.targetGeoPt!.longitude}',
          tag: _tag);
      // 不在地图移动时自动更新marker，避免频繁添加/删除marker
      // selectedLocation = mapStatus.targetGeoPt;
      // updateMarker(selectedLocation!);
      // update();
    }
  }

  /// 确认选择
  Future<AddressModel?> confirmSelection() async {
    if (selectedLocation == null) {
      ToastUtil.showWarning('请先在地图上选择位置');
      return null;
    }

    // 尝试获取当前位置的详细地址信息
    try {
      String address = selectedAddress;
      if (address.isEmpty || address.startsWith('经度:')) {
        return null; // 如果地址信息为空或以经度开头，则不进行地址解析
      }

      final addressModel = AddressModel(
        name: address,
        shortName:
            address.length > 20 ? '${address.substring(0, 20)}...' : address,
        province: locationService.currentProvince ?? '',
        city: locationService.currentCity ?? '',
        district: locationService.currentDistrict ?? '',
        street: address,
        latitude: selectedLocation!.latitude,
        longitude: selectedLocation!.longitude,
        isDefault: false,
      );

      return addressModel;
    } catch (e) {
      ToastUtil.showError('获取地址信息失败: $e');
      return null;
    }
  }
}
