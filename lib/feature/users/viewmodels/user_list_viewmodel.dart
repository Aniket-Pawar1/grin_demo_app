import 'package:flutter/foundation.dart';
import '../../../core/constants/api_constants.dart';
import '../models/users_response.dart';
import '../repositories/user_repository.dart';

class UserListViewModel extends ChangeNotifier {
  final UserRepository _repository;

  final List<ApiUser> _users = [];
  bool _isInitialLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUsers = 0;

  UserListViewModel({UserRepository? repository})
      : _repository = repository ?? UserRepositoryImpl();

  List<ApiUser> get users => List.unmodifiable(_users);
  bool get isInitialLoading => _isInitialLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalUsers => _totalUsers;
  bool get hasMore => _currentPage < _totalPages;
  bool get isEmpty => !_isInitialLoading && _users.isEmpty && _errorMessage == null;

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> fetchInitialUsers() async {
    _isInitialLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    notifyListeners();

    try {
      final response = await _repository.getUsers(
        page: _currentPage,
        perPage: ApiConstants.defaultPerPage,
      );

      _users.clear();
      _users.addAll(response.data);
      _currentPage = response.page;
      _totalPages = response.totalPages;
      _totalUsers = response.total;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || _isInitialLoading || !hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await _repository.getUsers(
        page: nextPage,
        perPage: ApiConstants.defaultPerPage,
      );

      _users.addAll(response.data);
      _currentPage = response.page;
      _totalPages = response.totalPages;
      _totalUsers = response.total;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refreshUsers() async {
    _errorMessage = null;
    try {
      final response = await _repository.getUsers(
        page: 1,
        perPage: ApiConstants.defaultPerPage,
      );

      _users.clear();
      _users.addAll(response.data);
      _currentPage = response.page;
      _totalPages = response.totalPages;
      _totalUsers = response.total;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }
}
