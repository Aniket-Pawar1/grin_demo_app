import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/app_exception.dart';

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {
                  ApiConstants.apiKeyHeader: ApiConstants.apiKey,
                  'Content-Type': 'application/json',
                },
              ),
            );

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw NetworkException(_mapDioError(e));
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException('Unexpected network error: $e');
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw NetworkException(_mapDioError(e));
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException('Unexpected network error: $e');
    }
  }

  String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your network connection.';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        return 'Server returned error ($status). Please try again later.';
      case DioExceptionType.connectionError:
        return 'Unable to connect to the server. Please check your internet connection.';
      default:
        return e.message ?? 'An unexpected network error occurred.';
    }
  }
}
