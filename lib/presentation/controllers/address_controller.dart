
import 'package:get/get.dart';
import 'package:door_to_door_service/core/models/address_model.dart';
import 'package:door_to_door_service/data/repositories/address_repository.dart';
import 'package:door_to_door_service/core/services/location_service.dart';
import 'package:door_to_door_service/core/utils/log_util.dart';

/// 地址控制器
/// 
/// 管理地址列表、当前选中的地址、搜索历史等状态
class AddressController extends GetxController {
  static const String _tag = 'AddressController';

  // 仓库实例
  final AddressRepository _repository = AddressRepository();

  // 定位服务
  final LocationService _locationService = Get.find<LocationService>();

  // 响应式状态
  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final Rx<AddressModel?> selectedAddress = Rx<AddressModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxList<AddressModel> searchResults = <AddressModel>[].obs;
  final RxString searchQuery = ''.obs;

  // 热门区域列表
  final RxList<AddressModel> popularAreas = <AddressModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadAddresses();
    _loadSelectedAddress();
    _loadPopularAreas();
  }

  /// 加载地址列表
  Future<void> _loadAddresses() async {
    try {
      isLoading.value = true;
      final result = await _repository.getAddresses();
      addresses.value = result;
      LogUtil.d('加载地址列表成功，共 ${result.length} 条', tag: _tag);
    } catch (e) {
      LogUtil.e('加载地址列表失败: $e', tag: _tag);
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载选中的地址
  Future<void> _loadSelectedAddress() async {
    try {
      final address = await _repository.getSelectedAddress();
      selectedAddress.value = address;
      LogUtil.d('加载选中地址成功: ${address?.name ?? "无"}', tag: _tag);
    } catch (e) {
      LogUtil.e('加载选中地址失败: $e', tag: _tag);
    }
  }

  /// 加载热门区域
  void _loadPopularAreas() {
    try {
      final city = _locationService.currentCity ?? '北京市';
      // 根据城市加载热门区域，这里使用模拟数据
      popularAreas.value = [
        AddressModel(
          id: 'area_1',
          name: '$city市中心',
          shortName: '市中心',
          province: _locationService.currentProvince ?? city,
          city: city,
          district: _locationService.currentDistrict ?? '',
          street: '市中心区域',
          latitude: _locationService.latitude ?? 0.0,
          longitude: _locationService.longitude ?? 0.0,
          isDefault: false,
        ),
        AddressModel(
          id: 'area_2',
          name: '$city商业区',
          shortName: '商业区',
          province: _locationService.currentProvince ?? city,
          city: city,
          district: _locationService.currentDistrict ?? '',
          street: '商业中心区域',
          latitude: _locationService.latitude ?? 0.0,
          longitude: _locationService.longitude ?? 0.0,
          isDefault: false,
        ),
        AddressModel(
          id: 'area_3',
          name: '$city科技园',
          shortName: '科技园',
          province: _locationService.currentProvince ?? city,
          city: city,
          district: _locationService.currentDistrict ?? '',
          street: '科技园区',
          latitude: _locationService.latitude ?? 0.0,
          longitude: _locationService.longitude ?? 0.0,
          isDefault: false,
        ),
      ];
      LogUtil.d('加载热门区域成功，共 ${popularAreas.length} 条', tag: _tag);
    } catch (e) {
      LogUtil.e('加载热门区域失败: $e', tag: _tag);
    }
  }

  /// 选择地址
  Future<void> selectAddress(AddressModel address) async {
    try {
      await _repository.setSelectedAddress(address.id);
      selectedAddress.value = address;
      LogUtil.d('选择地址成功: ${address.name}', tag: _tag);
      // 返回上一页
      Get.back(result: address);
    } catch (e) {
      LogUtil.e('选择地址失败: $e', tag: _tag);
    }
  }

  /// 添加地址
  Future<bool> addAddress(AddressModel address) async {
    try {
      isSaving.value = true;
      await _repository.addAddress(address);
      await _loadAddresses();
      await _loadSelectedAddress();
      LogUtil.d('添加地址成功: ${address.name}', tag: _tag);
      return true;
    } catch (e) {
      LogUtil.e('添加地址失败: $e', tag: _tag);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// 更新地址
  Future<bool> updateAddress(AddressModel address) async {
    try {
      isSaving.value = true;
      await _repository.updateAddress(address);
      await _loadAddresses();
      await _loadSelectedAddress();
      LogUtil.d('更新地址成功: ${address.name}', tag: _tag);
      return true;
    } catch (e) {
      LogUtil.e('更新地址失败: $e', tag: _tag);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// 删除地址
  Future<bool> deleteAddress(String addressId) async {
    try {
      await _repository.deleteAddress(addressId);
      await _loadAddresses();
      await _loadSelectedAddress();
      LogUtil.d('删除地址成功: $addressId', tag: _tag);
      return true;
    } catch (e) {
      LogUtil.e('删除地址失败: $e', tag: _tag);
      return false;
    }
  }

  /// 设置默认地址
  Future<bool> setDefaultAddress(String addressId) async {
    try {
      await _repository.setDefaultAddress(addressId);
      await _loadAddresses();
      await _loadSelectedAddress();
      LogUtil.d('设置默认地址成功: $addressId', tag: _tag);
      return true;
    } catch (e) {
      LogUtil.e('设置默认地址失败: $e', tag: _tag);
      return false;
    }
  }

  /// 搜索地址
  Future<void> searchAddresses(String query) async {
    try {
      searchQuery.value = query;

      if (query.isEmpty) {
        searchResults.clear();
        return;
      }

      // 在本地地址列表中搜索
      final results = addresses.where((address) {
        return address.name.toLowerCase().contains(query.toLowerCase()) ||
               address.shortName.toLowerCase().contains(query.toLowerCase()) ||
               address.street.toLowerCase().contains(query.toLowerCase());
      }).toList();

      searchResults.value = results;
      LogUtil.d('搜索地址成功，找到 ${results.length} 条结果', tag: _tag);
    } catch (e) {
      LogUtil.e('搜索地址失败: $e', tag: _tag);
    }
  }

  /// 清除搜索结果
  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
  }

  /// 获取当前定位地址
  AddressModel? getCurrentLocationAddress() {
    if (_locationService.currentAddress == null) {
      return null;
    }

    return AddressModel(
      id: 'current_location',
      name: _locationService.currentAddress ?? '当前位置',
      shortName: '当前位置',
      province: _locationService.currentProvince ?? '',
      city: _locationService.currentCity ?? '',
      district: _locationService.currentDistrict ?? '',
      street: _locationService.currentAddress ?? '',
      latitude: _locationService.latitude ?? 0.0,
      longitude: _locationService.longitude ?? 0.0,
      isDefault: false,
    );
  }

  /// 刷新数据
  Future<void> refresh() async {
    await _loadAddresses();
    await _loadSelectedAddress();
    _loadPopularAreas();
  }
}
