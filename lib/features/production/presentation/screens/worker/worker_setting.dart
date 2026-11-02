
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:golds_nuts/core/service_locator.dart';
import 'package:golds_nuts/core/utils/color_manager.dart';
import 'package:golds_nuts/features/auth/domain/entities/user_entity.dart';
import 'package:golds_nuts/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:golds_nuts/features/auth/presentation/bloc/logout/logout_bloc.dart';
import 'package:golds_nuts/features/auth/presentation/bloc/logout/logout_event.dart';
import 'package:golds_nuts/features/auth/presentation/bloc/logout/logout_state.dart';

// عدّل المسار ده حسب مكان LoginScreen عندك
import 'package:golds_nuts/features/auth/presentation/screens/login_screen.dart';

class WorkerSetting extends StatelessWidget {
  final UserEntity user;

  const WorkerSetting({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LogoutBloc>(),
      child: _WorkerSettingContent(user: user),
    );
  }
}

class _WorkerSettingContent extends StatelessWidget {
  final UserEntity user;

  const _WorkerSettingContent({required this.user});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                context.read<LogoutBloc>().add(
                  const LogoutRequested(),
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogoutBloc, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => sl<LoginBloc>(),
                child: const LoginScreen(),
              ),
            ),
                (route) => false,
          );
        }

        if (state is LogoutFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: ColorManager.background,
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: BlocBuilder<LogoutBloc, LogoutState>(
          builder: (context, state) {
            final isLoading = state is LogoutLoading;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 20),

                // Profile Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor:
                        ColorManager.primary.withValues(alpha: 0.12),
                        child: Icon(
                          Icons.person,
                          size: 55,
                          color: ColorManager.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user.role.toUpperCase(),
                        style: TextStyle(
                          color: ColorManager.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                _profileTile(
                  icon: Icons.person_outline,
                  title: 'Full Name',
                  value: user.name,
                ),

                _profileTile(
                  icon: Icons.email_outlined,
                  title: 'Email Address',
                  value: user.email,
                ),

                _profileTile(
                  icon: Icons.badge_outlined,
                  title: 'Account Role',
                  value: user.role,
                ),

                _profileTile(
                  icon: Icons.verified_user_outlined,
                  title: 'Account Status',
                  value: user.isActive ? 'Active' : 'Inactive',
                ),

                const SizedBox(height: 35),

                // Logout Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => _showLogoutDialog(context),
                    icon: isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.logout),
                    label: Text(
                      isLoading ? 'Logging out...' : 'Logout',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: ColorManager.primary,
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
