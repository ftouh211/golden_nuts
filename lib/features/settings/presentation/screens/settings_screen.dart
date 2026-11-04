import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/core/service_locator.dart';
import 'package:golds_nuts/core/utils/color_manager.dart';
import 'package:golds_nuts/core/services/fcm_token_manager.dart';
import 'package:golds_nuts/features/auth/domain/entities/user_entity.dart';
import 'package:golds_nuts/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:golds_nuts/features/auth/presentation/bloc/logout/logout_bloc.dart';
import 'package:golds_nuts/features/auth/presentation/bloc/logout/logout_event.dart';
import 'package:golds_nuts/features/auth/presentation/bloc/logout/logout_state.dart';
import 'package:golds_nuts/features/auth/presentation/screens/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SettingsScreen extends StatefulWidget {
  final UserEntity user;
  final VoidCallback onBack;

  const SettingsScreen({super.key, required this.user, required this.onBack});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  final FcmTokenManager _fcmTokenManager = sl<FcmTokenManager>();

  bool _notificationsEnabled = false;
  bool _isLoadingNotifications = true;
  bool _isUpdatingNotifications = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNotificationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadNotificationStatus();
    }
  }

  Future<void> _loadNotificationStatus() async {
    try {
      final isEnabled = await _fcmTokenManager.areNotificationsEnabled();

      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();

      final hasPermission =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      if (!mounted) return;

      setState(() {
        _notificationsEnabled = isEnabled && hasPermission;
        _isLoadingNotifications = false;
      });

      // If permission was revoked from system settings,
      // stop using this device's token.
      if (!hasPermission && isEnabled) {
        await _fcmTokenManager.unregisterDevice(uid: widget.user.uid);
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingNotifications = false;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (_isUpdatingNotifications) return;

    setState(() {
      _isUpdatingNotifications = true;
    });

    try {
      if (value) {
        final success = await _fcmTokenManager.requestPermissionAndRegister(
          uid: widget.user.uid,
        );

        if (!mounted) return;

        setState(() {
          _notificationsEnabled = success;
        });

        if (!success) {
          _showMessage('Notification permission was not granted.');
        } else {
          _showMessage('Notifications enabled successfully.');
        }
      } else {
        await _fcmTokenManager.unregisterDevice(uid: widget.user.uid);

        if (!mounted) return;

        setState(() {
          _notificationsEnabled = false;
        });

        _showMessage('Notifications disabled.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingNotifications = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        backgroundColor: ColorManager.background,
        elevation: 0,
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back),
          color: ColorManager.primary,
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: ColorManager.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Account Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ColorManager.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.user.role.toUpperCase(),
                        style: const TextStyle(
                          color: ColorManager.goldLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          _sectionTitle('Notifications'),

          _settingsCard(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),
                leading: _iconBox(
                  Icons.notifications_outlined,
                  ColorManager.gold,
                ),
                title: const Text(
                  'Push Notifications',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.textPrimary,
                  ),
                ),
                subtitle: Text(
                  _notificationsEnabled
                      ? 'You will receive notifications'
                      : 'Notifications are turned off',
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColorManager.textSecondary,
                  ),
                ),
                trailing: _isLoadingNotifications || _isUpdatingNotifications
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Switch.adaptive(
                        value: _notificationsEnabled,
                        activeColor: ColorManager.primary,
                        onChanged: _toggleNotifications,
                      ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _sectionTitle('Account'),

          _settingsCard(
            children: [
              _settingsTile(
                icon: Icons.person_outline,
                title: 'Full Name',
                subtitle: widget.user.name,
                iconColor: ColorManager.primary,
              ),
              _divider(),
              _settingsTile(
                icon: Icons.email_outlined,
                title: 'Email Address',
                subtitle: widget.user.email,
                iconColor: ColorManager.navy,
              ),
              _divider(),
              _settingsTile(
                icon: Icons.badge_outlined,
                title: 'Account Role',
                subtitle: widget.user.role.toUpperCase(),
                iconColor: ColorManager.nutBrown,
              ),
            ],
          ),

          const SizedBox(height: 24),

          _sectionTitle('Application'),

          _settingsCard(
            children: [
              _settingsTile(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'English',
                iconColor: ColorManager.primaryLight,
                trailing: const Text(
                  'English',
                  style: TextStyle(
                    color: ColorManager.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              _divider(),
              _settingsTile(
                icon: Icons.info_outline,
                title: 'About GoldsNuts',
                subtitle: 'Factory Management Application',
                iconColor: ColorManager.gold,
              ),
            ],
          ),

          const SizedBox(height: 28),

          _sectionTitle('Account Actions'),

          _settingsCard(
            children: [
              BlocConsumer<LogoutBloc, LogoutState>(
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
                    _showMessage(state.message);
                  }
                },
                builder: (context, state) {
                  final isLoading = state is LogoutLoading;

                  return ListTile(
                    onTap: isLoading
                        ? null
                        : () => _showLogoutConfirmation(context),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),
                    leading: _iconBox(Icons.logout_rounded, ColorManager.error),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.error,
                      ),
                    ),
                    subtitle: const Text(
                      'Sign out from your account',
                      style: TextStyle(
                        fontSize: 12,
                        color: ColorManager.textSecondary,
                      ),
                    ),
                    trailing: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.chevron_right,
                            color: ColorManager.error,
                          ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 28),

          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.eco_outlined,
                  color: ColorManager.primary,
                  size: 30,
                ),
                const SizedBox(height: 8),
                const Text(
                  'GoldsNuts',
                  style: TextStyle(
                    color: ColorManager.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Factory Management',
                  style: TextStyle(
                    color: ColorManager.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: ColorManager.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _settingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColorManager.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, color: ColorManager.divider);
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      leading: _iconBox(icon, iconColor),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: ColorManager.textPrimary,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: ColorManager.textSecondary,
          ),
        ),
      ),
      trailing: trailing,
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: ColorManager.surface,
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: ColorManager.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                context.read<LogoutBloc>().add(
                  LogoutRequested(uid: widget.user.uid),
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: ColorManager.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
