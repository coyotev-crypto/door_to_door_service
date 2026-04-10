import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../utils/log_util.dart';
import '../services/token_service.dart';

class DioClient {
  static DioClient? _instance;
  late Dio _dio;
  final TokenService _tokenService = TokenService.instance;
  bool _isRefreshing = false;

  DioClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: ApiConfig.connectTimeout),
      receiveTimeout: const Duration(seconds: ApiConfig.receiveTimeout),
      headers: ApiConfig.headers,
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
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
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
        // 使用LogUtil打印错误信息
        LogUtil.networkError(
          url: error.requestOptions.uri.toString(),
          error: error.message ?? '未知错误',
          statusCode: error.response?.statusCode,
        );

        // 处理401错误
        if (error.response?.statusCode == 401) {
          // 检查是否正在刷新Token
          if (_isRefreshing) {
            // 如果正在刷新，将请求加入队列
            // TODO: 实现请求队列
            return handler.next(error);
          }

          // 开始刷新Token
          _isRefreshing = true;

          try {
            // 检查刷新Token是否有效
            final refreshToken = await _tokenService.getRefreshToken();
            if (refreshToken == null || await _tokenService.isRefreshTokenExpired()) {
              // 刷新Token无效，清除所有Token
              await _tokenService.clearToken();
              // TODO: 跳转到登录页
              return handler.next(error);
            }

            // TODO: 调用刷新Token接口
            // 这里需要实现刷新Token的逻辑
            // 暂时清除Token并跳转到登录页
            await _tokenService.clearToken();
            // TODO: 跳转到登录页
          } catch (e) {
            LogUtil.e('刷新Token失败: $e');
            await _tokenService.clearToken();
            // TODO: 跳转到登录页
          } finally {
            _isRefreshing = false;
          }
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

  // GET请求
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
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
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
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
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
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
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
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
    } catch (e) {
      rethrow;
    }
  }
}
