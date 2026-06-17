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
    required int durationMinutes,
    required String startTime,
    required String addressName,
    required double latitude,
    required double longitude,
    required String contactName,
    required String contactPhone,
    String? remark,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.createOrder,
      data: {
        'serviceId': serviceId,
        'durationMinutes': durationMinutes,
        'startTime': startTime,
        'addressName': addressName,
        'latitude': latitude,
        'longitude': longitude,
        'contactName': contactName,
        'contactPhone': contactPhone,
        'remark': remark ?? '',
      },
    );
    return BaseResponse<dynamic>.fromJson(response.data);
  }

  /// 获取订单列表
  Future<BaseResponse<List<OrderModel>>> getOrderList({
    String? status,
    String? statuses,
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
    if (statuses != null) {
      queryParams['statuses'] = statuses;
    }
    final response = await _dioClient.get(
      ApiEndpoints.getOrderList,
      queryParameters: queryParams,
    );
    return BaseResponse<List<OrderModel>>.fromJson(
      response.data,
      dataParser: (data) {
        if (data is List) {
          return data
              .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        final map = data as Map<String, dynamic>;
        if (map['list'] is List) {
          return (map['list'] as List)
              .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <OrderModel>[];
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
  Future<BaseResponse<dynamic>> cancelOrder(int orderId, String reason) async {
    final path =
        ApiEndpoints.cancelOrder.replaceAll('{id}', orderId.toString());
    final response = await _dioClient.post(path, data: {
      'orderId': orderId,
      'reason': reason,
    });
    return BaseResponse<dynamic>.fromJson(response.data);
  }

  /// 申请退款
  Future<BaseResponse<dynamic>> requestRefund(
      int orderId, String reason) async {
    final path =
        ApiEndpoints.requestRefund.replaceAll('{id}', orderId.toString());
    final response = await _dioClient.post(path, data: {
      'orderId': orderId,
      'reason': reason,
    });
    return BaseResponse<dynamic>.fromJson(response.data);
  }

  // ═══ 服务商订单接口 ═══

  /// 服务商获取订单列表
  Future<BaseResponse<List<OrderModel>>> getProviderOrders({
    String? status,
    String? statuses,
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'pageIndex': pageIndex,
      'pageSize': pageSize,
    };
    if (status != null) queryParams['status'] = status;
    if (statuses != null) queryParams['statuses'] = statuses;
    final response = await _dioClient.get(
      ApiEndpoints.getProviderOrders,
      queryParameters: queryParams,
    );
    return BaseResponse<List<OrderModel>>.fromJson(
      response.data,
      dataParser: (data) {
        if (data is List) {
          return data
              .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        final map = data as Map<String, dynamic>;
        if (map['list'] is List) {
          return (map['list'] as List)
              .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <OrderModel>[];
      },
    );
  }

  /// 服务商接单
  Future<BaseResponse<dynamic>> acceptOrder(int id) async {
    final path =
        ApiEndpoints.acceptOrder.replaceAll('{id}', id.toString());
    final response = await _dioClient.post(path, data: {
      'orderId': id,
    });
    return BaseResponse<dynamic>.fromJson(response.data);
  }

  /// 服务商拒单
  Future<BaseResponse<dynamic>> rejectOrder(int id, String remark) async {
    final path =
        ApiEndpoints.rejectOrder.replaceAll('{id}', id.toString());
    final response = await _dioClient.post(path, data: {
      'orderId': id,
      'remark': remark,
    });
    return BaseResponse<dynamic>.fromJson(response.data);
  }

  /// 服务商出发
  Future<BaseResponse<dynamic>> enRouteOrder(int id) async {
    final path =
        ApiEndpoints.enRouteOrder.replaceAll('{id}', id.toString());
    final response = await _dioClient.post(path, data: {
      'orderId': id,
    });
    return BaseResponse<dynamic>.fromJson(response.data);
  }

  /// 开始服务
  Future<BaseResponse<dynamic>> startService(int id) async {
    final path =
        ApiEndpoints.startService.replaceAll('{id}', id.toString());
    final response = await _dioClient.post(path, data: {
      'orderId': id,
    });
    return BaseResponse<dynamic>.fromJson(response.data);
  }

  /// 完成服务
  Future<BaseResponse<dynamic>> completeService(int id) async {
    final path =
        ApiEndpoints.completeService.replaceAll('{id}', id.toString());
    final response = await _dioClient.post(path, data: {
      'orderId': id,
    });
    return BaseResponse<dynamic>.fromJson(response.data);
  }
}
