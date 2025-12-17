import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:your_finance_flutter/core/utils/logger.dart';

/// HTTP service using Dio - for future cloud sync capabilities
/// Provides type-safe HTTP operations with interceptors for logging and error handling
class DioHttpService {
  DioHttpService._();
  static DioHttpService? _instance;
  late final Dio _dio;

  static Future<DioHttpService> getInstance() async {
    _instance ??= DioHttpService._();
    await _instance!._initialize();
    return _instance!;
  }

  Future<void> _initialize() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent':
              'YourFinance/${Platform.isIOS ? 'iOS' : Platform.isAndroid ? 'Android' : 'Web'}',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      _LoggingInterceptor(),
      _ErrorInterceptor(),
      _RetryInterceptor(),
    ]);

    Log.business(
      'DioHttpService',
      'HTTP Service Initialized',
      {'baseUrl': _getBaseUrl(), 'platform': Platform.operatingSystem},
    );
  }

  String _getBaseUrl() {
    // For now, use a placeholder. In production, this would come from environment variables
    // or a configuration service
    // TODO: 配置开发环境的有效API端点
    return 'https://api.yourfinance.com/v1';
  }

  // ============================================================================
  // HTTP Methods
  // ============================================================================

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      Log.error(
        'DioHttpService',
        'GET request failed',
        {'path': path, 'error': e.toString()},
      );
      rethrow;
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      Log.error(
        'DioHttpService',
        'POST request failed',
        {'path': path, 'error': e.toString()},
      );
      rethrow;
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      Log.error(
        'DioHttpService',
        'PUT request failed',
        {'path': path, 'error': e.toString()},
      );
      rethrow;
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      Log.error(
        'DioHttpService',
        'DELETE request failed',
        {'path': path, 'error': e.toString()},
      );
      rethrow;
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      Log.error(
        'DioHttpService',
        'PATCH request failed',
        {'path': path, 'error': e.toString()},
      );
      rethrow;
    }
  }

  // ============================================================================
  // File Upload/Download
  // ============================================================================

  /// Upload file
  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    String method = 'POST',
    String? fileName,
    String? mimeType,
    Map<String, dynamic>? extraData,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final file = File(filePath);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName ?? file.path.split('/').last,
          contentType: mimeType != null ? DioMediaType.parse(mimeType) : null,
        ),
        if (extraData != null) ...extraData,
      });

      final response = await _dio.request<T>(
        path,
        data: formData,
        options: Options(method: method),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      return response;
    } catch (e) {
      Log.error(
        'DioHttpService',
        'File upload failed',
        {'path': path, 'error': e.toString()},
      );
      rethrow;
    }
  }

  /// Download file
  Future<Response<dynamic>> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
  }) async {
    try {
      final response = await _dio.download(
        url,
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
      Log.error(
        'DioHttpService',
        'File download failed',
        {'url': url, 'error': e.toString()},
      );
      rethrow;
    }
  }

  // ============================================================================
  // Utility Methods
  // ============================================================================

  /// Cancel all ongoing requests
  void cancelAllRequests() {
    _dio.close(force: true);
    Log.business('DioHttpService', 'All requests cancelled');
  }

  /// Update authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    Log.business('DioHttpService', 'Auth token updated');
  }

  /// Clear authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
    Log.business('DioHttpService', 'Auth token cleared');
  }

  /// Update base URL (useful for switching environments)
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
    Log.business('DioHttpService', 'Base URL updated', {'baseUrl': baseUrl});
  }
}

// ============================================================================
// Interceptors
// ============================================================================

/// Logging interceptor for debugging and monitoring
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      Log.business('HTTP Request', options.method, {
        'url': options.uri.toString(),
        'headers': options.headers,
        'data': options.data,
        'query': options.queryParameters,
      });
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      Log.business('HTTP Response', response.statusCode.toString(), {
        'url': response.requestOptions.uri.toString(),
        'data': response.data,
        'headers': response.headers.map,
      });
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Log.error('HTTP Error', err.message ?? 'Unknown error', {
      'url': err.requestOptions.uri.toString(),
      'method': err.requestOptions.method,
      'status': err.response?.statusCode,
      'response': err.response?.data,
    });
    super.onError(err, handler);
  }
}

/// Error interceptor for handling common error scenarios
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        err = DioException(
          requestOptions: err.requestOptions,
          error: '网络连接超时，请检查网络连接',
          type: err.type,
        );
      case DioExceptionType.connectionError:
        err = DioException(
          requestOptions: err.requestOptions,
          error: '网络连接失败，请检查网络设置',
          type: err.type,
        );
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        var message = '请求失败';

        switch (statusCode) {
          case 400:
            message = '请求参数错误';
          case 401:
            message = '未授权访问';
          case 403:
            message = '访问被拒绝';
          case 404:
            message = '资源不存在';
          case 500:
            message = '服务器内部错误';
          case 502:
          case 503:
          case 504:
            message = '服务器暂时不可用';
        }

        err = DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          error: message,
          type: err.type,
        );
      default:
        err = DioException(
          requestOptions: err.requestOptions,
          error: '网络请求失败，请稍后重试',
          type: err.type,
        );
    }

    super.onError(err, handler);
  }
}

/// Retry interceptor for handling temporary failures
class _RetryInterceptor extends Interceptor {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;

    // Only retry on network errors, not on bad responses
    if (_shouldRetry(err) &&
        ((requestOptions.extra['retryCount'] as int?) ?? 0) < maxRetries) {
      requestOptions.extra['retryCount'] =
          (requestOptions.extra['retryCount'] ?? 0) + 1;

      Log.business('HTTP Retry', 'Retrying request', {
        'attempt': requestOptions.extra['retryCount'],
        'url': requestOptions.uri.toString(),
      });

      await Future<void>.delayed(retryDelay);
      final retryDio = Dio(
        BaseOptions(
          baseUrl: requestOptions.baseUrl,
          connectTimeout: requestOptions.connectTimeout,
          receiveTimeout: requestOptions.receiveTimeout,
          sendTimeout: requestOptions.sendTimeout,
          headers: requestOptions.headers,
        ),
      );

      try {
        final response = await retryDio.request<dynamic>(
          requestOptions.path,
          options: Options(method: requestOptions.method),
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
        );
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) =>
      err.type == DioExceptionType.connectionTimeout ||
      err.type == DioExceptionType.connectionError ||
      err.type == DioExceptionType.receiveTimeout ||
      err.type == DioExceptionType.sendTimeout ||
      (err.type == DioExceptionType.badResponse &&
          err.response?.statusCode != null &&
          err.response!.statusCode! >= 500);
}
