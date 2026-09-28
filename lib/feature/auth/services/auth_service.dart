import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/app_exception.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(
          (user) => user != null ? UserModel.fromFirebaseUser(user) : null,
        );
  }

  UserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('User profile could not be retrieved.');
      }
      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Failed to create user account.');
      }
      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out: $e');
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    
    // if (e.code == 'CONFIGURATION_NOT_FOUND' ||
    //     (e.message?.contains('CONFIGURATION_NOT_FOUND') ?? false)) {
    //   return 'Email/Password sign-in is not enabled in Firebase Console. Please enable it in Authentication > Sign-in method.';
    // }

    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is disabled in Firebase.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'network-request-failed':
        return 'Network connection error. Please verify your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
