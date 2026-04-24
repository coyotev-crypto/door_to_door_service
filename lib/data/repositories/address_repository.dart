
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:door_to_door_service/core/models/address_model.dart';
import 'package:door_to_door_service/core/utils/log_util.dart';

/// 地址仓库
/// 
/// 负责地址数据的增删改查操作，包括本地存储和网络请求
class AddressRepository {
  static const String _tag = 'AddressRepository';
  static const String _addressesKey = 'user_addresses';
  static const String _selectedAddressIdKey = 'selected_address_id';

  /// 获取所有地址列表
  Future<List<AddressModel>> getAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = prefs.getString(_addressesKey);

      if (addressesJson == null || addressesJson.isEmpty) {
        // 返回默认的模拟数据
        return _getMockAddresses();
      }

      final List<dynamic> jsonList = json.decode(addressesJson);
      return jsonList
          .map((json) => AddressModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LogUtil.e('获取地址列表失败: $e', tag: _tag);
      // 发生错误时返回模拟数据
      return _getMockAddresses();
    }
  }

  /// 保存地址列表
  Future<void> saveAddresses(List<AddressModel> addresses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = json.encode(
        addresses.map((address) => address.toJson()).toList(),
      );
      await prefs.setString(_addressesKey, addressesJson);
      LogUtil.d('保存地址列表成功，共 ${addresses.length} 条', tag: _tag);
    } catch (e) {
      LogUtil.e('保存地址列表失败: $e', tag: _tag);
      rethrow;
    }
  }

  /// 获取选中的地址
  Future<AddressModel?> getSelectedAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedId = prefs.getString(_selectedAddressIdKey);

      if (selectedId == null || selectedId.isEmpty) {
        return null;
      }

      final addresses = await getAddresses();
      try {
        return addresses.firstWhere((address) => address.id == selectedId);
      } catch (e) {
        return null;
      }
    } catch (e) {
      LogUtil.e('获取选中地址失败: $e', tag: _tag);
      return null;
    }
  }

  /// 设置选中的地址
  Future<void> setSelectedAddress(String addressId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedAddressIdKey, addressId);
      LogUtil.d('设置选中地址: $addressId', tag: _tag);
    } catch (e) {
      LogUtil.e('设置选中地址失败: $e', tag: _tag);
      rethrow;
    }
  }

  /// 添加地址
  Future<AddressModel> addAddress(AddressModel address) async {
    try {
      final addresses = await getAddresses();

      // 如果设置为默认地址，先取消其他默认地址
      if (address.isDefault) {
        addresses.forEach((a) => a.copyWith(isDefault: false));
      }

      addresses.add(address);
      await saveAddresses(addresses);

      // 如果是默认地址，设置为选中地址
      if (address.isDefault) {
        await setSelectedAddress(address.id);
      }

      LogUtil.d('添加地址成功: ${address.name}', tag: _tag);
      return address;
    } catch (e) {
      LogUtil.e('添加地址失败: $e', tag: _tag);
      rethrow;
    }
  }

  /// 更新地址
  Future<AddressModel> updateAddress(AddressModel address) async {
    try {
      final addresses = await getAddresses();
      final index = addresses.indexWhere((a) => a.id == address.id);

      if (index == -1) {
        throw Exception('地址不存在');
      }

      // 如果设置为默认地址，先取消其他默认地址
      if (address.isDefault) {
        addresses.forEach((a) => a.copyWith(isDefault: false));
      }

      addresses[index] = address;
      await saveAddresses(addresses);

      // 如果是默认地址，设置为选中地址
      if (address.isDefault) {
        await setSelectedAddress(address.id);
      }

      LogUtil.d('更新地址成功: ${address.name}', tag: _tag);
      return address;
    } catch (e) {
      LogUtil.e('更新地址失败: $e', tag: _tag);
      rethrow;
    }
  }

  /// 删除地址
  Future<void> deleteAddress(String addressId) async {
    try {
      final addresses = await getAddresses();
      addresses.removeWhere((a) => a.id == addressId);
      await saveAddresses(addresses);

      // 如果删除的是选中的地址，清除选中状态
      final selectedAddress = await getSelectedAddress();
      if (selectedAddress?.id == addressId) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_selectedAddressIdKey);
      }

      LogUtil.d('删除地址成功: $addressId', tag: _tag);
    } catch (e) {
      LogUtil.e('删除地址失败: $e', tag: _tag);
      rethrow;
    }
  }

  /// 设置默认地址
  Future<void> setDefaultAddress(String addressId) async {
    try {
      final addresses = await getAddresses();

      // 取消所有默认地址
      final updatedAddresses = addresses.map((a) {
        return a.copyWith(isDefault: a.id == addressId);
      }).toList();

      await saveAddresses(updatedAddresses);
      await setSelectedAddress(addressId);

      LogUtil.d('设置默认地址成功: $addressId', tag: _tag);
    } catch (e) {
      LogUtil.e('设置默认地址失败: $e', tag: _tag);
      rethrow;
    }
  }

  /// 获取模拟地址数据
  List<AddressModel> _getMockAddresses() {
    return [
      AddressModel(
        id: '1',
        name: '北京市朝阳区建国路88号SOHO现代城A座',
        shortName: 'SOHO现代城A座',
        province: '北京市',
        city: '北京市',
        district: '朝阳区',
        street: '建国路88号SOHO现代城A座',
        latitude: 39.908823,
        longitude: 116.397470,
        isDefault: true,
        contactName: '张三',
        contactPhone: '13800138000',
      ),
      AddressModel(
        id: '2',
        name: '北京市海淀区中关村大街1号',
        shortName: '中关村大街1号',
        province: '北京市',
        city: '北京市',
        district: '海淀区',
        street: '中关村大街1号',
        latitude: 39.982345,
        longitude: 116.318567,
        isDefault: false,
        contactName: '李四',
        contactPhone: '13900139000',
      ),
      AddressModel(
        id: '3',
        name: '北京市东城区王府井大街255号',
        shortName: '王府井大街255号',
        province: '北京市',
        city: '北京市',
        district: '东城区',
        street: '王府井大街255号',
        latitude: 39.915678,
        longitude: 116.412345,
        isDefault: false,
        contactName: '王五',
        contactPhone: '13700137000',
      ),
    ];
  }
}
