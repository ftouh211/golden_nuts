import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:golds_nuts/config/routes_manager/routes.dart';
import 'package:golds_nuts/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:golds_nuts/features/auth/presentation/bloc/login/login_event.dart';
import 'package:golds_nuts/features/auth/presentation/bloc/login/login_state.dart';
import 'package:golds_nuts/features/production/presentation/screens/worker/worker_dash_board_screen.dart';
import 'package:golds_nuts/core/services/fcm_token_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login(BuildContext context) {
    if (formKey.currentState!.validate()) {
      context.read<LoginBloc>().add(
        LoginSubmitted(
          email: emailController.text.trim(),
          password: passwordController.text,
        ),
      );
    }
  }

  Future<void> _handleLoginSuccess(LoginSuccess state) async {
    final user = state.user;

    final prefs = await SharedPreferences.getInstance();
    final promptKey = 'notification_prompt_shown_${user.uid}';

    final hasShownPrompt = prefs.getBool(promptKey) ?? false;

    if (!hasShownPrompt && mounted) {
      // Save before showing the dialog to avoid repeating it.
      await prefs.setBool(promptKey, true);

      final shouldEnable = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons.notifications_active_outlined,
              size: 40,
              color: Color(0xFF174D3A),
            ),
            title: const Text('Enable Notifications'),
            content: const Text(
              'Would you like to receive notifications about your production and factory updates?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: const Text('Maybe Later'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                child: const Text('Enable Notifications'),
              ),
            ],
          );
        },
      );

      if (shouldEnable == true) {
        try {
          await GetIt.I<FcmTokenManager>().requestPermissionAndRegister(
            uid: user.uid,
          );
        } catch (e) {
          // Notification errors must not block login.
        }
      }
    }

    if (!mounted) return;

    // Navigate according to user role.
    if (user.role == 'manager') {
      Navigator.pushReplacementNamed(
        context,
        Routes.managerDashboardScreenRoute,
        arguments: user,
      );
    } else if (user.role == 'worker') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => WorkerDashboardScreen(user: user)),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) async {
        if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }

        if (state is LoginSuccess) {
          await _handleLoginSuccess(state);
        }
      },
      builder: (context, state) {
        final isLoading = state is LoginLoading;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.eco, size: 80, color: Color(0xFF174D3A)),

                      const SizedBox(height: 16),

                      const Text(
                        'GoldsNuts',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Welcome Back!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),

                      const SizedBox(height: 40),

                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }

                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: isLoading ? null : () => login(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF174D3A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
