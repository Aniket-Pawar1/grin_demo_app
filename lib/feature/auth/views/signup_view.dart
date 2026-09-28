import 'package:flutter/material.dart';
import '../viewmodels/auth_viewmodel.dart';

class SignupView extends StatefulWidget {
  final AuthViewModel authViewModel;

  const SignupView({super.key, required this.authViewModel});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _obscurePassword = ValueNotifier<bool>(true);
  final _obscureConfirmPassword = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _obscurePassword.dispose();
    _obscureConfirmPassword.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    widget.authViewModel.clearError();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    final success = await widget.authViewModel.signUp(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please sign in.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, _emailController.text.trim());
    } else if (!success && mounted) {
      final error = widget.authViewModel.errorMessage ?? 'Signup failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () {
              widget.authViewModel.clearError();
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: ListenableBuilder(
                  listenable: widget.authViewModel,
                  builder: (context, _) {
                    final isLoading = widget.authViewModel.isLoading;
                    final errorMessage = widget.authViewModel.errorMessage;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(theme, colorScheme),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.all(28.0),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(24.0),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Register New Account',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Set up your credentials to join the directory.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 22),
                              if (errorMessage != null) ...[
                                _buildErrorBanner(colorScheme, errorMessage),
                                const SizedBox(height: 18),
                              ],
                              _buildEmailField(isLoading),
                              const SizedBox(height: 16),
                              _buildPasswordField(isLoading),
                              const SizedBox(height: 16),
                              _buildConfirmPasswordField(isLoading),
                              const SizedBox(height: 24),
                              _buildSubmitButton(isLoading, colorScheme),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildSignInPrompt(isLoading, colorScheme),
                        const SizedBox(height: 12),
                        _buildSecurityFooter(colorScheme),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF06B6D4), Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_rounded,
            size: 38,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Create Account',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start exploring team members and company directory',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(ColorScheme colorScheme, String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(bool isLoading) {
    return TextFormField(
      controller: _emailController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      enabled: !isLoading,
      decoration: const InputDecoration(
        labelText: 'Email Address',
        hintText: 'name@example.com',
        prefixIcon: Icon(Icons.mail_outline_rounded),
      ),
      validator: (value) {
        final email = value?.trim() ?? '';
        if (email.isEmpty) return 'Please enter your email';
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
        if (!emailRegex.hasMatch(email)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(bool isLoading) {
    return ValueListenableBuilder<bool>(
      valueListenable: _obscurePassword,
      builder: (context, obscure, _) {
        return TextFormField(
          controller: _passwordController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          obscureText: obscure,
          textInputAction: TextInputAction.next,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Min. 6 characters',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () => _obscurePassword.value = !_obscurePassword.value,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter your password';
            if (value.length < 6) return 'Password must be at least 6 characters';
            return null;
          },
        );
      },
    );
  }

  Widget _buildConfirmPasswordField(bool isLoading) {
    return ValueListenableBuilder<bool>(
      valueListenable: _obscureConfirmPassword,
      builder: (context, obscure, _) {
        return TextFormField(
          controller: _confirmPasswordController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          obscureText: obscure,
          textInputAction: TextInputAction.done,
          enabled: !isLoading,
          onFieldSubmitted: (_) => _handleSignUp(),
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            hintText: 'Re-enter your password',
            prefixIcon: const Icon(Icons.lock_reset_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () =>
                  _obscureConfirmPassword.value = !_obscureConfirmPassword.value,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please confirm your password';
            if (value != _passwordController.text) return 'Passwords do not match';
            return null;
          },
        );
      },
    );
  }

  Widget _buildSubmitButton(bool isLoading, ColorScheme colorScheme) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: isLoading ? null : _handleSignUp,
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildSignInPrompt(bool isLoading, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  widget.authViewModel.clearError();
                  Navigator.pop(context);
                },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: const Text(
            'Sign In',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityFooter(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.shield_outlined,
          size: 14,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Text(
          'Secured with Firebase Authentication',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
