import '../models/service_list_response_model.dart';
import '../models/favorite_list_response_model.dart';
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
    double? radius,
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

      if (radius != null) {
        queryParams['radius'] = radius;
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

  /// 切换服务收藏状态
  /// [serviceId] 服务ID
  /// [isFavorite] 是否收藏
  Future<Map<String, dynamic>> toggleFavorite({
    required int serviceId,
    required bool isFavorite,
  }) async {
    try {
      if (isFavorite) {
        final response = await _dioClient.post(
          ApiEndpoints.toggleFavoriteService,
          data: {'serviceId': serviceId, 'isFavorite': isFavorite},
        );
        return response.data as Map<String, dynamic>;
      } else {
        final response = await _dioClient.delete(
          ApiEndpoints.deleteFavoriteService
              .replaceFirst('{id}', serviceId.toString()),
        );
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 获取收藏列表
  Future<FavoriteListResponseModel> getFavorites({
    required int userId,
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'userId': userId,
        'pageIndex': pageIndex,
        'pageSize': pageSize,
      };
      final response = await _dioClient.get(
        ApiEndpoints.getFavorites,
        queryParameters: queryParams,
      );
      return FavoriteListResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
