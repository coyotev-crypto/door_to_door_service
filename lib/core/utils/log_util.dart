import 'dart:developer' as developer;
// 导入JSON编码器
import 'dart:convert';

/// 日志工具类
class LogUtil {
  // 是否启用日志，生产环境可以设置为false
  static const bool _enableLog = true;

  // 日志标签
  static const String _tag = 'DoorToDoorService';

  /// 打印普通日志
  static void d(String message, {String? tag}) {
    if (!_enableLog) return;
    final logTag = tag ?? _tag;
    developer.log(
      message,
      name: logTag,
      time: DateTime.now(),
    );
  }

  /// 打印错误日志
  static void e(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    if (!_enableLog) return;
    final logTag = tag ?? _tag;
    developer.log(
      message,
      name: logTag,
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      level: 1000, // error level
    );
  }

  /// 打印警告日志
  static void w(String message, {String? tag}) {
    if (!_enableLog) return;
    final logTag = tag ?? _tag;
    developer.log(
      message,
      name: logTag,
      time: DateTime.now(),
      level: 900, // warning level
    );
  }

  /// 打印信息日志
  static void i(String message, {String? tag}) {
    if (!_enableLog) return;
    final logTag = tag ?? _tag;
    developer.log(
      message,
      name: logTag,
      time: DateTime.now(),
      level: 800, // info level
    );
  }

  /// 打印JSON格式数据
  static void json(String message, {String? tag}) {
    if (!_enableLog) return;
    final logTag = tag ?? _tag;
    developer.log(
      message,
      name: logTag,
      time: DateTime.now(),
    );
  }

  /// 打印网络请求
  static void networkRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) {
    if (!_enableLog) return;

    d('========== 请求开始 ==========');
    d('请求方法: $method');
    d('请求URL: $url');

    if (headers != null && headers.isNotEmpty) {
      d('请求头: $headers');
    }

    if (queryParameters != null && queryParameters.isNotEmpty) {
      d('查询参数: $queryParameters');
    }

    if (data != null) {
      if (data is Map || data is List) {
        try {
          final prettyData = const JsonEncoder.withIndent('  ').convert(data);
          d('请求体:$prettyData');
        } catch (e) {
          d('请求体: $data');
        }
      } else {
        d('请求体: $data');
      }
    }

    d('========== 请求结束 ==========');
  }

  /// 打印网络响应
  static void networkResponse({
    required String url,
    required int? statusCode,
    dynamic data,
  }) {
    if (!_enableLog) return;

    d('========== 响应开始 ==========');
    d('响应URL: $url');
    d('响应状态码: $statusCode');

    if (data != null) {
      if (data is Map || data is List) {
        try {
          final prettyData = const JsonEncoder.withIndent('  ').convert(data);
          d('响应数据:$prettyData');
        } catch (e) {
          d('响应数据: $data');
        }
      } else {
        d('响应数据: $data');
      }
    }

    d('========== 响应结束 ==========');
  }

  /// 打印网络错误
  static void networkError({
    required String url,
    required String error,
    int? statusCode,
  }) {
    if (!_enableLog) return;

    e('========== 网络错误 ==========');
    e('请求URL: $url');
    if (statusCode != null) {
      e('状态码: $statusCode');
    }
    e('错误信息: $error');
    e('========== 错误结束 ==========');
  }
}
