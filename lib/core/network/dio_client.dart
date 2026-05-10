import 'package:dio/dio.dart';
import 'package:door_to_door_service/core/utils/toast_util.dart';
import 'package:door_to_door_service/routes/route_names.dart';
import 'package:door_to_door_service/core/services/auth_service.dart';
import 'package:get/get.dart' as GetX;
import '../config/app_config.dart';
import '../utils/log_util.dart';
import '../services/token_service.dart';

class DioClient {
  static DioClient? _instance;
  late Dio _dio;
  final TokenService _tokenService = TokenService.instance;

  // 存储每个请求的CancelToken，key为请求的唯一标识
  final Map<String, CancelToken> _cancelTokens = {};

  DioClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseApiUrl,
      connectTimeout: const Duration(seconds: AppConfig.connectTimeout),
      sendTimeout: const Duration(seconds: AppConfig.sendTimeout),
      receiveTimeout: const Duration(seconds: AppConfig.receiveTimeout),
      headers: AppConfig.headers,
    ));

    // 添加拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 使用LogUtil打印请求信息
        LogUtil.networkRequest(
          method: options.method,
          url: options.uri.toString(),
          headers: options.headers,
          queryParameters: options.queryParameters,
          data: options.data is FormData ? 'FormData (文件上传)' : options.data,
        );

        // 添加token到请求头
        final token = await _tokenService.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // 使用LogUtil打印响应信息
        LogUtil.networkResponse(
          url: response.requestOptions.uri.toString(),
          statusCode: response.statusCode,
          data: response.data,
        );

        // 如果是取消请求（状态码为499），直接返回响应，不处理
        if (response.statusCode == 499) {
          return handler.next(response);
        }

        // 解析响应数据
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          final code = data['code'] as int? ?? -1;
          final message = data['msg'] as String? ?? '';

          // 检查响应码
          if (code != 200) {
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                message: message,
              ),
            );
          }

          // 保留完整的响应数据，包括code、message、data等字段
          // 这样可以保留token等额外字段
        }
        return handler.next(response);
      },
      onError: (error, handler) async {
        // 如果是取消请求，不打印错误日志
        if (error.type != DioExceptionType.cancel) {
          // 使用LogUtil打印错误信息
          LogUtil.networkError(
            url: error.requestOptions.uri.toString(),
            error: error.message ?? '未知错误',
            statusCode: error.response?.statusCode,
          );
        }

        // 处理401错误
        if (error.response?.statusCode == 401) {
          // 清除Token和用户信息
          await _tokenService.clearToken();
          await AuthService.instance.logout();

          // 跳转到登录界面并显示提示
          GetX.Get.offAllNamed(RouteNames.login);
          ToastUtil.showWarning('登录失效，请重新登录');
        }
        return handler.next(error);
      },
    ));
  }

  static DioClient get instance {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  /// 生成请求的唯一标识
  String _generateRequestKey(String method, String path,
      {Map<String, dynamic>? queryParameters, dynamic data}) {
    // 将参数转换为字符串并排序，确保相同的参数生成相同的key
    // String paramsKey = '';
    // if (queryParameters != null && queryParameters.isNotEmpty) {
    //   final sortedKeys = queryParameters.keys.toList()..sort();
    //   paramsKey = sortedKeys.map((k) => '$k=${queryParameters[k]}').join('&');
    // }
    // if (data != null && data is! FormData) {
    //   final dataStr = data.toString();
    //   paramsKey = paramsKey.isEmpty ? dataStr : '$paramsKey&$dataStr';
    // }
    // return '${method}_$path${paramsKey.isEmpty ? '' : '?$paramsKey'}';
    // 只使用path作为请求的唯一标识，不包含参数
    return '${method}_$path';
  }

  /// 取消指定key的请求
  void _cancelRequest(String key) {
    if (_cancelTokens.containsKey(key)) {
      LogUtil.d('取消请求: $key', tag: 'DioClient');
      _cancelTokens[key]?.cancel('请求已取消：新请求已发起');
      _cancelTokens.remove(key);
    }
  }

  /// 清理所有取消令牌
  void clearCancelTokens() {
    _cancelTokens.clear();
  }

  // GET请求
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool cancelPrevious = true, // 是否取消之前的相同请求
  }) async {
    // 生成请求唯一标识
    final requestKey =
        _generateRequestKey('GET', path, queryParameters: queryParameters);

    // 如果需要取消之前的请求
    if (cancelPrevious) {
      _cancelRequest(requestKey);
    }

    // 创建新的CancelToken
    final newCancelToken = CancelToken();
    _cancelTokens[requestKey] = newCancelToken;

    // 如果外部提供了cancelToken，则合并使用
    final effectiveCancelToken = cancelToken ?? newCancelToken;

    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: effectiveCancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      // 请求成功后移除cancelToken
      _cancelTokens.remove(requestKey);

      return response;
    } on DioException catch (e) {
      // 请求失败或被取消后移除cancelToken
      _cancelTokens.remove(requestKey);

      // 如果是取消请求，打印日志但不抛出异常
      if (e.type == DioExceptionType.cancel) {
        LogUtil.d('GET请求已取消: $requestKey', tag: 'DioClient');
        return Response(
          requestOptions: e.requestOptions,
          statusCode: 499,
          statusMessage: '请求已取消',
          data: <String, dynamic>{'code': 499, 'msg': '请求已取消'},
        );
      }

      rethrow;
    } catch (e) {
      // 请求失败或被取消后移除cancelToken
      _cancelTokens.remove(requestKey);
      rethrow;
    }
  }

  // POST请求
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool cancelPrevious = true, // 是否取消之前的相同请求
  }) async {
    // 生成请求唯一标识
    final requestKey = _generateRequestKey('POST', path,
        queryParameters: queryParameters, data: data);

    // 如果需要取消之前的请求
    if (cancelPrevious) {
      _cancelRequest(requestKey);
    }

    // 创建新的CancelToken
    final newCancelToken = CancelToken();
    _cancelTokens[requestKey] = newCancelToken;

    // 如果外部提供了cancelToken，则合并使用
    final effectiveCancelToken = cancelToken ?? newCancelToken;

    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: effectiveCancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      // 请求成功后移除cancelToken
      _cancelTokens.remove(requestKey);

      return response;
    } on DioException catch (e) {
      // 请求失败或被取消后移除cancelToken
      _cancelTokens.remove(requestKey);

      // 如果是取消请求，打印日志但不抛出异常
      if (e.type == DioExceptionType.cancel) {
        LogUtil.d('POST请求已取消: $requestKey', tag: 'DioClient');
        return Response(
          requestOptions: e.requestOptions,
          statusCode: 499, // 使用499表示客户端关闭请求
          statusMessage: '请求已取消',
        );
      }

      rethrow;
    } catch (e) {
      // 请求失败或被取消后移除cancelToken
      _cancelTokens.remove(requestKey);
      rethrow;
    }
  }

  // PUT请求
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool cancelPrevious = true, // 是否取消之前的相同请求
  }) async {
    // 生成请求唯一标识
    final requestKey = _generateRequestKey('PUT', path,
        queryParameters: queryParameters, data: data);

    // 如果需要取消之前的请求
    if (cancelPrevious) {
      _cancelRequest(requestKey);
    }

    // 创建新的CancelToken
    final newCancelToken = CancelToken();
    _cancelTokens[requestKey] = newCancelToken;

    // 如果外部提供了cancelToken，则合并使用
    final effectiveCancelToken = cancelToken ?? newCancelToken;

    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: effectiveCancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      // 请求成功后移除cancelToken
      _cancelTokens.remove(requestKey);

      return response;
    } on DioException catch (e) {
      // 请求失败或被取消后移除cancelToken
      _cancelTokens.remove(requestKey);

      // 如果是取消请求，打印日志但不抛出异常
      if (e.type == DioExceptionType.cancel) {
        LogUtil.d('PUT请求已取消: $requestKey', tag: 'DioClient');
        return Response(
          requestOptions: e.requestOptions,
          statusCode: 499, // 使用499表示客户端关闭请求
          statusMessage: '请求已取消',
        );
      }

      rethrow;
    } catch (e) {
      // 请求失败或被取消后移除cancelToken
      _cancelTokens.remove(requestKey);
      rethrow;
    }
  }

  // DELETE请求
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool cancelPrevious = true, // 是否取消之前的相同请求
  }) async {
    // 生成请求唯一标识
    final requestKey = _generateRequestKey('DELETE', path,
        queryParameters: queryParameters, data: data);

    // 如果需要取消之前的请求
    if (cancelPrevious) {
      _cancelRequest(requestKey);
    }

    // 创建新的CancelToken
    final newCancelToken = CancelToken();
    _cancelTokens[requestKey] = newCancelToken;

    // 如果外部提供了cancelToken，则合并使用
    final effectiveCancelToken = cancelToken ?? newCancelToken;

    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: effectiveCancelToken,
      );

      // 请求成功后移除cancelToken
      _cancelTokens.remove(requestKey);

      return response;
    } on DioException catch (e) {
      // 请求失败或被取消后移除cancelToken
      _cancelTokens.remove(requestKey);

      // 如果是取消请求，打印日志但不抛出异常
      if (e.type == DioExceptionType.cancel) {
        LogUtil.d('DELETE请求已取消: $requestKey', tag: 'DioClient');
        return Response(
          requestOptions: e.requestOptions,
          statusCode: 499, // 使用499表示客户端关闭请求
          statusMessage: '请求已取消',
        );
      }

      rethrow;
    } catch (e) {
      // 请求失败或被取消后移除cancelToken
      _cancelTokens.remove(requestKey);
      rethrow;
    }
  }

  // 下载文件
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    dynamic data,
    Options? options,
  }) async {
    try {
      final response = await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        data: data,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      // 如果是取消请求，打印日志但不抛出异常
      if (e.type == DioExceptionType.cancel) {
        LogUtil.d('下载请求已取消: $urlPath', tag: 'DioClient');
        return Response(
          requestOptions: e.requestOptions,
          statusCode: 499,
          statusMessage: '请求已取消',
          data: <String, dynamic>{'code': 499, 'msg': '请求已取消'},
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
