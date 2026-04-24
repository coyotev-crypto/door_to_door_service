import '../models/category_list_response_model.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';

class CategoryRepository {
  final DioClient _dioClient;

  CategoryRepository() : _dioClient = DioClient.instance;

  /// 获取一级分类列表
  Future<CategoryListResponseModel> getPrimaryCategories({
    int pageIndex = 1,
    int pageSize = 20,
    String orderBy = 'hot',
  }) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.getCategories,
        queryParameters: {
          'parentId': 0,
          'orderBy': orderBy,
          'pageIndex': pageIndex,
          'pageSize': pageSize,
        },
      );
      return CategoryListResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// 获取二级分类列表
  Future<CategoryListResponseModel> getSecondaryCategories({
    required int parentId,
    int pageIndex = 1,
    int pageSize = 20,
    String orderBy = 'hot',
  }) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.getCategories,
        queryParameters: {
          'parentId': parentId,
          'orderBy': orderBy,
          'pageIndex': pageIndex,
          'pageSize': pageSize,
        },
      );
      return CategoryListResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// 获取分类列表（通用方法）
  Future<CategoryListResponseModel> getCategories({
    int? parentId,
    String? orderBy,
    int pageIndex = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'pageIndex': pageIndex,
        'pageSize': pageSize,
      };

      if (parentId != null) {
        queryParams['parentId'] = parentId;
      }

      if (orderBy != null) {
        queryParams['orderBy'] = orderBy;
      }

      final response = await _dioClient.get(
        ApiEndpoints.getCategories,
        queryParameters: queryParams,
      );
      return CategoryListResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
