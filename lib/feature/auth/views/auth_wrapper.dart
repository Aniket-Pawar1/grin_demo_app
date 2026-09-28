import 'package:flutter/material.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../users/views/user_list_view.dart';
import 'login_view.dart';

class AuthWrapper extends StatelessWidget {
  final AuthViewModel authViewModel;

  const AuthWrapper({super.key, required this.authViewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authViewModel,
      builder: (context, _) {
        if (authViewModel.isAuthenticated) {
          return UserListView(authViewModel: authViewModel);
        } else {
          return LoginView(authViewModel: authViewModel);
        }
      },
    );
  }
}
