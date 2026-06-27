import 'package:dtd/data/models/service_item.dart';

import '../../core/network/base_response.dart';

/// 收藏项模型
class FavoriteItem {
  /// 收藏ID
  final int id;
  
  /// 用户ID
  final int userId;
  
  /// 服务ID
  final int serviceId;
  
  /// 创建时间
  final String createTime;
  
  /// 服务信息
  final ServiceItem service;

  FavoriteItem({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.createTime,
    required this.service,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      serviceId: json['serviceId'] as int? ?? 0,
      createTime: json['createTime'] as String? ?? '',
      service: ServiceItem.fromJson(json['Service'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'serviceId': serviceId,
      'createTime': createTime,
      'Service': service.toJson(),
    };
  }
}

/// 收藏列表响应模型
class FavoriteListResponseModel extends BaseResponse {
  /// 收藏列表
  final List<FavoriteItem>? list;

  /// 总数量
  final int? count;

  /// 当前页码
  final int? page;

  /// 每页数量
  final int? pageSize;

  FavoriteListResponseModel({
    required super.code,
    required super.message,
    this.list,
    this.count,
    this.page,
    this.pageSize,
  });

  factory FavoriteListResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return FavoriteListResponseModel(
      code: json['code'] as int? ?? -1,
      message: json['msg'] as String? ?? json['message'] as String? ?? '',
      list: data?['list'] != null
          ? (data!['list'] as List)
              .map((e) => FavoriteItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      count: data?['count'] as int?,
      page: data?['page'] as int?,
      pageSize: data?['pageSize'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'data': {
        'list': list?.map((e) => e.toJson()).toList(),
        'count': count,
        'page': page,
        'pageSize': pageSize,
      },
    };
  }
}
