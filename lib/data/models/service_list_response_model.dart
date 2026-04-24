import '../../core/network/base_response.dart';
import '../../core/models/service_item.dart';

/// 服务列表响应模型
class ServiceListResponseModel extends BaseResponse {
  /// 服务列表
  final List<ServiceItem>? list;

  /// 总数量
  final int? count;

  /// 当前页码
  final int? pageIndex;

  /// 每页数量
  final int? pageSize;

  /// 新人推荐列表
  final List<ServiceItem>? newcomerList;

  ServiceListResponseModel({
    required super.code,
    required super.message,
    this.list,
    this.count,
    this.pageIndex,
    this.pageSize,
    this.newcomerList,
  });

  factory ServiceListResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return ServiceListResponseModel(
      code: json['code'] as int? ?? -1,
      message: json['msg'] as String? ?? json['message'] as String? ?? '',
      list: data?['list'] != null
          ? (data!['list'] as List)
              .map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      count: data?['count'] as int?,
      pageIndex: data?['page'] as int? ?? data?['pageIndex'] as int?,
      pageSize: data?['pageSize'] as int?,
      newcomerList: data?['newcomerList'] != null
          ? (data!['newcomerList'] as List)
              .map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'data': {
        'list': list?.map((e) => e.toJson()).toList(),
        'count': count,
        'page': pageIndex,
        'pageSize': pageSize,
        'newcomerList': newcomerList?.map((e) => e.toJson()).toList(),
      },
    };
  }
}
