import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }

  @override
  String toString() => 'UserModel(uid: $uid, email: $email, displayName: $displayName)';
}
