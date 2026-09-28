import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/api_service.dart';
import '../models/users_response.dart';

abstract class UserRepository {
  Future<UsersResponse> getUsers({
    required int page,
    int perPage = ApiConstants.defaultPerPage,
  });
}

class UserRepositoryImpl implements UserRepository {
  final ApiService _apiService;

  UserRepositoryImpl({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  @override
  Future<UsersResponse> getUsers({
    required int page,
    int perPage = ApiConstants.defaultPerPage,
  }) async {
    final data = await _apiService.get(
      '/users',
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );

    if (data is Map<String, dynamic>) {
      return UsersResponse.fromJson(data);
    }
    throw const NetworkException('Invalid response format received from server.');
  }
}
