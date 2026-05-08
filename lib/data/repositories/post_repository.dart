import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/post_list_response_model.dart';
import '../../core/network/base_response.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';

/// 帖子仓库类
class PostRepository {
  final DioClient _dioClient;

  PostRepository() : _dioClient = DioClient.instance;

  /// 获取帖子列表
  Future<PostListResponseModel> getPostList({
    int pageIndex = 1,
    int pageSize = 10,
    String? sortBy, // 'latest' | 'hot'
  }) async {
    final queryParams = <String, dynamic>{
      'pageIndex': pageIndex,
      'pageSize': pageSize,
    };
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    final response = await _dioClient.get(
      ApiEndpoints.getPostList,
      queryParameters: queryParams,
    );
    return PostListResponseModel.fromJson(response.data);
  }

  /// 获取帖子详情
  Future<BaseResponse<PostModel>> getPostDetail(int id) async {
    final path = ApiEndpoints.getPostDetail.replaceAll('{id}', id.toString());
    final response = await _dioClient.get(path);
    return BaseResponse<PostModel>.fromJson(
      response.data,
      dataParser: (data) => PostModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 发布帖子
  Future<BaseResponse<PostModel>> createPost({
    required String title,
    required String content,
    required List<String> images,
    required List<String> tags,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.createPost,
      data: {
        'title': title,
        'content': content,
        'images': images,
        'tags': tags,
      },
    );
    return BaseResponse<PostModel>.fromJson(
      response.data,
      dataParser: (data) => PostModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 删除帖子
  Future<BaseResponse<dynamic>> deletePost(int id) async {
    final path = ApiEndpoints.deletePost.replaceAll('{id}', id.toString());
    final response = await _dioClient.delete(path);
    return BaseResponse<dynamic>.fromJson(response.data);
  }

  /// 点赞/取消点赞帖子
  Future<BaseResponse<dynamic>> toggleLike(int postId) async {
    final path =
        ApiEndpoints.togglePostLike.replaceAll('{id}', postId.toString());
    final response = await _dioClient.post(path);
    return BaseResponse<dynamic>.fromJson(response.data);
  }

  /// 收藏/取消收藏帖子
  Future<BaseResponse<dynamic>> toggleCollect(int postId) async {
    final path =
        ApiEndpoints.togglePostCollect.replaceAll('{id}', postId.toString());
    final response = await _dioClient.post(path);
    return BaseResponse<dynamic>.fromJson(response.data);
  }

  /// 获取评论列表
  Future<BaseResponse<List<CommentModel>>> getComments({
    required int postId,
    int pageIndex = 1,
    int pageSize = 20,
  }) async {
    final path = ApiEndpoints.getComments.replaceAll('{id}', postId.toString());
    final response = await _dioClient.get(
      path,
      queryParameters: {'pageIndex': pageIndex, 'pageSize': pageSize},
    );
    return BaseResponse<List<CommentModel>>.fromJson(
      response.data,
      dataParser: (data) {
        final list = data as List<dynamic>;
        return list
            .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// 发表评论
  Future<BaseResponse<CommentModel>> createComment({
    required int postId,
    required String content,
    int? parentId,
  }) async {
    final path =
        ApiEndpoints.createComment.replaceAll('{id}', postId.toString());
    final response = await _dioClient.post(
      path,
      data: {
        'content': content,
        if (parentId != null) 'parentId': parentId,
      },
    );
    return BaseResponse<CommentModel>.fromJson(
      response.data,
      dataParser: (data) =>
          CommentModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 删除评论
  Future<BaseResponse<dynamic>> deleteComment(int id) async {
    final path = ApiEndpoints.deleteComment.replaceAll('{id}', id.toString());
    final response = await _dioClient.delete(path);
    return BaseResponse<dynamic>.fromJson(response.data);
  }

  /// 评论点赞
  Future<BaseResponse<dynamic>> toggleCommentLike(int id) async {
    final path =
        ApiEndpoints.toggleCommentLike.replaceAll('{id}', id.toString());
    final response = await _dioClient.post(path);
    return BaseResponse<dynamic>.fromJson(response.data);
  }
}
