import '../models/service_item.dart';
import '../models/service_list_response_model.dart';
import '../models/favorite_list_response_model.dart';
import '../../core/network/base_response.dart';
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

  /// 创建服务
  Future<BaseResponse<dynamic>> createService({
    required int categoryId,
    required String name,
    required double price,
    required String providerName,
    required String address,
    required double deliveryRange,
    double? travelFee,
    double? latitude,
    double? longitude,
    int status = 1,
    List<Map<String, dynamic>>? timeSlots,
    List<Map<String, dynamic>>? specialDateSlots,
    List<Map<String, dynamic>>? prices,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.createService,
      data: {
        'address': address,
        'categoryId': categoryId,
        'deliveryRange': deliveryRange,
        'latitude': latitude,
        'longitude': longitude,
        'name': name,
        'price': price,
        'providerName': providerName,
        'status': status,
        'travelFee': travelFee,
        'timeSlots': timeSlots ?? [],
        'specialDateSlots': specialDateSlots ?? [],
        'prices': prices ?? [],
      },
    );
    return BaseResponse<dynamic>.fromJson(response.data);
  }

  /// 更新服务
  Future<BaseResponse<dynamic>> updateService({
    required int id,
    required int categoryId,
    required String name,
    required double price,
    required String providerName,
    required String address,
    required double deliveryRange,
    double? travelFee,
    double? latitude,
    double? longitude,
    int status = 1,
    List<Map<String, dynamic>>? timeSlots,
    List<Map<String, dynamic>>? specialDateSlots,
    List<Map<String, dynamic>>? prices,
  }) async {
    final path = ApiEndpoints.updateService.replaceAll('{id}', id.toString());
    final response = await _dioClient.put(
      path,
      data: {
        'address': address,
        'categoryId': categoryId,
        'deliveryRange': deliveryRange,
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
        'name': name,
        'price': price,
        'providerName': providerName,
        'status': status,
        'travelFee': travelFee,
        'timeSlots': timeSlots ?? [],
        'specialDateSlots': specialDateSlots ?? [],
        'prices': prices ?? [],
      },
    );
    return BaseResponse<dynamic>.fromJson(response.data);
  }

  /// 获取我的服务列表
  Future<BaseResponse<List<ServiceItem>>> getMyServices({
    int pageIndex = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.get(
      ApiEndpoints.getMyServices,
      queryParameters: {
        'pageIndex': pageIndex,
        'pageSize': pageSize,
      },
    );
    return BaseResponse<List<ServiceItem>>.fromJson(
      response.data,
      dataParser: (data) {
        final list = data as List<dynamic>;
        return list
            .map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// 根据ID获取服务详情
  Future<BaseResponse<ServiceItem>> getServiceById(int id) async {
    final path = ApiEndpoints.getServiceById.replaceAll('{id}', id.toString());
    final response = await _dioClient.get(path);
    return BaseResponse<ServiceItem>.fromJson(
      response.data,
      dataParser: (data) => ServiceItem.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 上架服务
  Future<BaseResponse<dynamic>> publishService(int id) async {
    final path =
        ApiEndpoints.publishService.replaceAll('{id}', id.toString());
    final response = await _dioClient.put(path);
    return BaseResponse<dynamic>.fromJson(response.data);
  }

  /// 下架服务
  Future<BaseResponse<dynamic>> unpublishService(int id) async {
    final path =
        ApiEndpoints.unpublishService.replaceAll('{id}', id.toString());
    final response = await _dioClient.put(path);
    return BaseResponse<dynamic>.fromJson(response.data);
  }
}
