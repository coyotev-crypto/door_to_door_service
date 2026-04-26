import 'dart:ffi';

import 'package:door_to_door_service/data/models/address_model.dart';
import 'package:door_to_door_service/core/utils/log_util.dart';
import 'package:door_to_door_service/core/network/dio_client.dart';
import 'package:door_to_door_service/core/network/api_endpoints.dart';
import 'package:door_to_door_service/core/network/base_response.dart';

/// 地址仓库
///
/// 负责地址数据的增删改查操作，包括本地存储和网络请求
class AddressRepository {
  static const String _tag = 'AddressRepository';

  /// 从服务器获取地址列表，支持分页、筛选、排序
  Future<List<AddressModel>> getAddressListFromServer({
    String? userId,
    String? province,
    String? city,
    String? district,
    bool? isDefault,
    int pageSize = 20,
    int pageIndex = 1,
  }) async {
    try {
      // 构建查询参数
      final Map<String, dynamic> queryParams = {
        'pageSize': pageSize,
        'pageIndex': pageIndex,
      };

      // 添加可选参数
      if (userId != null && userId.isNotEmpty) {
        queryParams['userId'] = userId;
      }
      if (province != null && province.isNotEmpty) {
        queryParams['province'] = province;
      }
      if (city != null && city.isNotEmpty) {
        queryParams['city'] = city;
      }
      if (district != null && district.isNotEmpty) {
        queryParams['district'] = district;
      }
      if (isDefault != null) {
        queryParams['isDefault'] = isDefault;
      }

      // 发送请求
      final response = await DioClient.instance.get(
        ApiEndpoints.getAddressList,
        queryParameters: queryParams,
      );

      // 解析响应
      if (response.statusCode == 200 && response.data != null) {
        final baseResponse = BaseResponse.fromJson(
          response.data as Map<String, dynamic>,
          dataParser: (data) {
            if (data is Map<String, dynamic> && data.containsKey('list')) {
              // 如果返回的数据包含list字段，解析list
              final list = data['list'] as List<dynamic>;
              return list
                  .map((item) =>
                      AddressModel.fromJson(item as Map<String, dynamic>))
                  .toList();
            } else if (data is List) {
              // 如果返回的数据本身就是列表，直接解析
              return data
                  .map((item) =>
                      AddressModel.fromJson(item as Map<String, dynamic>))
                  .toList();
            }
            return <AddressModel>[];
          },
        );

        if (baseResponse.isSuccess && baseResponse.data != null) {
          return baseResponse.data as List<AddressModel>;
        }
      }

      // 请求失败或数据格式不正确，返回空列表
      LogUtil.e('获取地址列表失败: ${response.data}', tag: _tag);
      return <AddressModel>[];
    } catch (e) {
      LogUtil.e('获取地址列表异常: $e', tag: _tag);
      // 发生异常时返回空列表
      return <AddressModel>[];
    }
  }

  /// 添加地址
  Future<void> addAddress(AddressModel address) async {
    try {
      // 发送请求到服务器
      final response = await DioClient.instance.post(
        ApiEndpoints.createAddress,
        data: address.toJson(),
      );

      // 解析响应
      if (response.statusCode == 200 && response.data != null) {
        final baseResponse = BaseResponse.fromJson(
          response.data as Map<String, dynamic>,
        );

        if (baseResponse.isSuccess) {
          LogUtil.d('添加地址成功: ${address.name}', tag: _tag);
          return;
        }
      }

      // 请求失败或数据格式不正确
      LogUtil.e('添加地址失败: ${response.data}', tag: _tag);
      throw Exception('添加地址失败');
    } catch (e) {
      LogUtil.e('添加地址异常: $e', tag: _tag);
      rethrow;
    }
  }

  /// 更新地址
  Future<AddressModel> updateAddress(AddressModel address) async {
    try {
      // 发送请求到服务器
      final response = await DioClient.instance.put(
        ApiEndpoints.updateAddress.replaceAll('{id}', address.id.toString()),
        data: address.toJson(),
      );

      // 解析响应
      if (response.statusCode == 200 && response.data != null) {
        final baseResponse = BaseResponse.fromJson(
          response.data as Map<String, dynamic>,
          dataParser: (data) {
            if (data is Map<String, dynamic>) {
              return AddressModel.fromJson(data);
            }
            // 如果返回的data只是一个ID而不是完整对象，返回null
            return null;
          },
        );

        // 检查响应是否成功
        if (baseResponse.isSuccess) {
          LogUtil.d('更新地址成功: ${address.name}', tag: _tag);
          // 如果服务器返回的是完整的地址对象，则使用返回的对象
          // 如果服务器返回的只是ID或其他标识，则使用传入的address对象
          return baseResponse.data ?? address;
        }
      }
      // 请求失败或数据格式不正确
      LogUtil.e('更新地址失败: ${response.data}', tag: _tag);
      throw Exception('更新地址失败');
    } catch (e) {
      LogUtil.e('更新地址异常: $e', tag: _tag);
      rethrow;
    }
  }

  /// 删除地址
  Future<void> deleteAddress(int addressId) async {
    try {
      // 发送请求到服务器
      final response = await DioClient.instance.delete(
        ApiEndpoints.deleteAddress.replaceAll('{id}', addressId.toString()),
      );

      // 解析响应
      if (response.statusCode == 200 && response.data != null) {
        final baseResponse = BaseResponse.fromJson(
          response.data as Map<String, dynamic>,
        );

        if (baseResponse.isSuccess) {
          LogUtil.d('删除地址成功: $addressId', tag: _tag);
          return;
        }
      }

      // 请求失败或数据格式不正确
      LogUtil.e('删除地址失败: ${response.data}', tag: _tag);
      throw Exception('删除地址失败');
    } catch (e) {
      LogUtil.e('删除地址异常: $e', tag: _tag);
      rethrow;
    }
  }

  /// 设置默认地址
  Future<void> setDefaultAddress(int addressId) async {
    try {
      // 发送请求到服务器
      final response = await DioClient.instance.put(
        ApiEndpoints.setDefaultAddress.replaceAll('{id}', addressId.toString()),
      );

      // 解析响应
      if (response.statusCode == 200 && response.data != null) {
        final baseResponse = BaseResponse.fromJson(
          response.data as Map<String, dynamic>,
        );

        if (baseResponse.isSuccess) {
          LogUtil.d('设置默认地址成功: $addressId', tag: _tag);
          return;
        }
      }

      // 请求失败或数据格式不正确
      LogUtil.e('设置默认地址失败: ${response.data}', tag: _tag);
      throw Exception('设置默认地址失败');
    } catch (e) {
      LogUtil.e('设置默认地址异常: $e', tag: _tag);
      rethrow;
    }
  }
}
