import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<UserModel?>? _authSubscription;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isRegistering = false;

  AuthViewModel({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _currentUser = _authService.currentUser;
    _authSubscription = _authService.authStateChanges.listen((user) {
      if (_isRegistering) return;
      _currentUser = user;
      notifyListeners();
    });
  }

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _currentUser = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    _isRegistering = true;
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _authService.signOut();
      _currentUser = null;
      _isRegistering = false;
      _setLoading(false);
      return true;
    } catch (e) {
      _isRegistering = false;
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.signOut();
      _currentUser = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
