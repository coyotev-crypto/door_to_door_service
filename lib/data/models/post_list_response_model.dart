import 'post_model.dart';

/// 帖子列表响应模型
class PostListResponseModel {
  final List<PostModel>? list;
  final int? count;
  final int? pageIndex;
  final int? pageSize;

  PostListResponseModel({this.list, this.count, this.pageIndex, this.pageSize});

  factory PostListResponseModel.fromJson(Map<String, dynamic> json) {
    return PostListResponseModel(
      list: (json['data'] as List<dynamic>?)
          ?.map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int?,
      pageIndex: json['pageIndex'] as int?,
      pageSize: json['pageSize'] as int?,
    );
  }
}
