import 'package:shared_preferences/shared_preferences.dart';
import 'package:city_pickers/city_pickers.dart';

/// 城市服务类
/// 负责管理城市信息的存储和获取
class CityService {
  static final CityService _instance = CityService._internal();
  factory CityService() => _instance;
  CityService._internal();

  static const String _keySelectedCity = 'selected_city';
  static const String _keySelectedCityCode = 'selected_city_code';
  static const String _keySelectedProvince = 'selected_province';
  static const String _keySelectedProvinceCode = 'selected_province_code';
  static const String _keySelectedArea = 'selected_area';
  static const String _keySelectedAreaCode = 'selected_area_code';

  /// 获取当前选中的城市
  Future<Result> getSelectedCity() async {
    final prefs = await SharedPreferences.getInstance();
    final cityName = prefs.getString(_keySelectedCity);
    final cityCode = prefs.getString(_keySelectedCityCode);
    final provinceName = prefs.getString(_keySelectedProvince);
    final provinceCode = prefs.getString(_keySelectedProvinceCode);
    final areaName = prefs.getString(_keySelectedArea);
    final areaCode = prefs.getString(_keySelectedAreaCode);

    if (cityName != null && cityCode != null) {
      return Result(
        cityName: cityName,
        cityId: cityCode,
        provinceName: provinceName,
        provinceId: provinceCode,
        areaName: areaName,
        areaId: areaCode,
      );
    }

    // 默认返回北京
    return Result(
      cityName: '北京',
      cityId: '110000',
      provinceName: '北京',
      provinceId: '110000',
    );
  }

  /// 保存选中的城市
  Future<void> saveSelectedCity(Result result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedCity, result.cityName ?? '');
    await prefs.setString(_keySelectedCityCode, result.cityId ?? '');
    await prefs.setString(_keySelectedProvince, result.provinceName ?? '');
    await prefs.setString(_keySelectedProvinceCode, result.provinceId ?? '');
    await prefs.setString(_keySelectedArea, result.areaName ?? '');
    await prefs.setString(_keySelectedAreaCode, result.areaId ?? '');
  }

  /// 清除城市信息
  Future<void> clearCity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySelectedCity);
    await prefs.remove(_keySelectedCityCode);
    await prefs.remove(_keySelectedProvince);
    await prefs.remove(_keySelectedProvinceCode);
    await prefs.remove(_keySelectedArea);
    await prefs.remove(_keySelectedAreaCode);
  }
}
