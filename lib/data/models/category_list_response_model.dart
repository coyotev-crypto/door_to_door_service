import '../../core/network/base_response.dart';
import 'category_model.dart';

/// 分类列表响应模型
class CategoryListResponseModel extends BaseResponse {
  /// 分类列表
  final List<CategoryModel>? list;

  /// 总数量
  final int? total;

  CategoryListResponseModel({
    required super.code,
    required super.message,
    this.list,
    this.total,
  });

  factory CategoryListResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return CategoryListResponseModel(
      code: json['code'] as int? ?? -1,
      message: json['msg'] as String? ?? json['message'] as String? ?? '',
      list: data?['list'] != null
          ? (data!['list'] as List)
              .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      total: data?['total'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'data': {
        'list': list?.map((e) => e.toJson()).toList(),
        'total': total,
      },
    };
  }
}
