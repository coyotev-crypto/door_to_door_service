import 'post_model.dart';

/// 帖子列表响应模型
class PostListResponseModel {
  final List<PostModel>? list;
  final int? count;
  final int? pageIndex;
  final int? pageSize;

  PostListResponseModel({this.list, this.count, this.pageIndex, this.pageSize});

  factory PostListResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return PostListResponseModel(
      list: (data?['list'] as List<dynamic>?)
          ?.map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: data?['count'] as int?,
      pageIndex: data?['pageIndex'] as int?,
      pageSize: data?['pageSize'] as int?,
    );
  }
}
