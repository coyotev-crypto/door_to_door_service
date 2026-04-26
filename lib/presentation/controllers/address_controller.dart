import 'dart:ffi';

import 'package:get/get.dart';
import 'package:door_to_door_service/data/models/address_model.dart';
import 'package:door_to_door_service/data/repositories/address_repository.dart';
import 'package:door_to_door_service/core/services/location_service.dart';
import 'package:door_to_door_service/core/services/auth_service.dart';
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
  }

  /// 加载地址列表
  Future<void> _loadAddresses() async {
    try {
      isLoading.value = true;

      // 获取当前用户ID
      final userId = AuthService.instance.user?.id;

      // 从服务器获取地址列表
      final result = await _repository.getAddressListFromServer(
        userId: userId,
        pageSize: 100, // 获取足够多的地址
        pageIndex: 1,
      );

      addresses.value = result;
      LogUtil.d('从服务器加载地址列表成功，共 ${result.length} 条', tag: _tag);
    } catch (e) {
      LogUtil.e('加载地址列表失败: $e', tag: _tag);
    } finally {
      isLoading.value = false;
    }
  }

  /// 选择地址
  Future<void> selectAddress(AddressModel address) async {
    try {
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
  Future<bool> deleteAddress(int addressId) async {
    try {
      await _repository.deleteAddress(addressId);
      await _loadAddresses();
      LogUtil.d('删除地址成功: $addressId', tag: _tag);
      return true;
    } catch (e) {
      LogUtil.e('删除地址失败: $e', tag: _tag);
      return false;
    }
  }

  /// 设置默认地址
  Future<bool> setDefaultAddress(int addressId) async {
    try {
      await _repository.setDefaultAddress(addressId);
      await _loadAddresses();
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
            address.street.toLowerCase().contains(query.toLowerCase()) ||
            address.city.toLowerCase().contains(query.toLowerCase()) ||
            address.contactName?.toLowerCase().contains(query.toLowerCase()) ==
                true;
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
      id: 0,
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
  }
}
