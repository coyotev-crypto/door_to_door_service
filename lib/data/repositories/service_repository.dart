import '../models/service_list_response_model.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';

class ServiceRepository {
  final DioClient _dioClient;

  ServiceRepository() : _dioClient = DioClient.instance;

  /// 获取服务列表
  Future<ServiceListResponseModel> getServiceList({
    int? categoryId,
    int pageIndex = 1,
    int pageSize = 10,
    String? ratingOrder,
    String? priceOrder,
    String? orderCountOrder,
    String? distanceOrder,
    String? createTimeOrder,
    String? provinceId,
    String? cityId,
    String? areaId,
    String? keyword,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'pageIndex': pageIndex,
        'pageSize': pageSize,
      };

      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }

      if (ratingOrder != null) {
        queryParams['ratingOrder'] = ratingOrder;
      }

      if (priceOrder != null) {
        queryParams['priceOrder'] = priceOrder;
      }

      if (orderCountOrder != null) {
        queryParams['orderCountOrder'] = orderCountOrder;
      }

      if (distanceOrder != null) {
        queryParams['distanceOrder'] = distanceOrder;
      }

      if (createTimeOrder != null) {
        queryParams['createTimeOrder'] = createTimeOrder;
      }

      if (provinceId != null) {
        queryParams['provinceId'] = provinceId;
      }

      if (cityId != null) {
        queryParams['cityId'] = cityId;
      }

      if (areaId != null) {
        queryParams['areaId'] = areaId;
      }

      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }

      if (latitude != null) {
        queryParams['latitude'] = latitude;
      }

      if (longitude != null) {
        queryParams['longitude'] = longitude;
      }

      final response = await _dioClient.get(
        ApiEndpoints.getServiceList,
        queryParameters: queryParams,
      );
      return ServiceListResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// 更新服务
  /// [serviceId] 服务ID
  /// [isFavorite] 是否收藏
  Future<Map<String, dynamic>> updateService({
    required int serviceId,
    bool? isFavorite,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (isFavorite != null) {
        data['isFavorite'] = isFavorite;
      }

      final endpoint = ApiEndpoints.updateService.replaceAll('{id}', serviceId.toString());
      final response = await _dioClient.put(
        endpoint,
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
