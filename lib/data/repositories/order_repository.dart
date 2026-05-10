import '../models/order_model.dart';
import '../../core/network/base_response.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';

/// 订单仓库类
class OrderRepository {
  final DioClient _dioClient;

  OrderRepository() : _dioClient = DioClient.instance;

  /// 创建订单
  Future<BaseResponse<dynamic>> createOrder({
    required int serviceId,
    required String addressName,
    required double latitude,
    required double longitude,
    required String contactName,
    required String contactPhone,
    String? remark,
    String? serviceTime,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.createOrder,
      data: {
        'serviceId': serviceId,
        'addressName': addressName,
        'latitude': latitude,
        'longitude': longitude,
        'contactName': contactName,
        'contactPhone': contactPhone,
        'remark': remark ?? '',
        'serviceTime': serviceTime ?? '',
      },
    );
    return BaseResponse<dynamic>.fromJson(response.data);
  }

  /// 获取订单列表
  Future<BaseResponse<List<OrderModel>>> getOrderList({
    int? status,
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'pageIndex': pageIndex,
      'pageSize': pageSize,
    };
    if (status != null) {
      queryParams['status'] = status;
    }
    final response = await _dioClient.get(
      ApiEndpoints.getOrderList,
      queryParameters: queryParams,
    );
    return BaseResponse<List<OrderModel>>.fromJson(
      response.data,
      dataParser: (data) {
        final list = data as List<dynamic>;
        return list
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// 获取订单详情
  Future<BaseResponse<OrderModel>> getOrderDetail(int orderId) async {
    final response = await _dioClient.get(
      ApiEndpoints.getOrderDetail,
      queryParameters: {'id': orderId},
    );
    return BaseResponse<OrderModel>.fromJson(
      response.data,
      dataParser: (data) => OrderModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 取消订单
  Future<BaseResponse<dynamic>> cancelOrder(int orderId) async {
    final response = await _dioClient.post(
      ApiEndpoints.cancelOrder,
      data: {'id': orderId},
    );
    return BaseResponse<dynamic>.fromJson(response.data);
  }
}
