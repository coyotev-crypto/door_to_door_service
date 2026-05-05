/// 网络请求响应基类
/// 统一处理API响应数据格式
class BaseResponse<T> {
  /// 请求ID
  final String? requestId;

  /// 响应码
  final int code;

  /// 响应消息
  final String message;

  /// 响应数据
  final T? data;

  /// 是否成功
  bool get isSuccess => code == 200;

  BaseResponse({
    this.requestId,
    required this.code,
    required this.message,
    this.data,
  });

  /// 从JSON创建实例
  factory BaseResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? dataParser,
  }) {
    return BaseResponse<T>(
      requestId: json['requestId']?.toString(),
      code: json['code'] as int? ?? -1,
      message: json['msg'] as String? ?? json['message'] as String? ?? '',
      data: dataParser != null && json['data'] != null
          ? dataParser(json['data'])
          : json['data'] as T?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'code': code,
      'message': message,
      'data': data,
    };
  }

  /// 创建成功响应
  factory BaseResponse.success({
    T? data,
    String message = '操作成功',
  }) {
    return BaseResponse<T>(
      code: 200,
      message: message,
      data: data,
    );
  }

  /// 创建失败响应
  factory BaseResponse.error({
    required String message,
    int code = -1,
    T? data,
  }) {
    return BaseResponse<T>(
      code: code,
      message: message,
      data: data,
    );
  }

  @override
  String toString() {
    return 'BaseResponse{requestId: $requestId, code: $code, message: $message, data: $data}';
  }
}
