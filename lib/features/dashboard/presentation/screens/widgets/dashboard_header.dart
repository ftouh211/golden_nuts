
import 'package:flutter/material.dart';
import 'package:golds_nuts/core/utils/color_manager.dart';
import 'package:golds_nuts/features/auth/domain/entities/user_entity.dart';
import 'package:golds_nuts/features/notifications/presentation/screens/notifications_screen.dart';

class DashboardHeader extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onSettingsTap;

  const DashboardHeader({
    super.key,
    required this.user,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final greeting = now.hour < 12
        ? 'Good Morning'
        : now.hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
      decoration: const BoxDecoration(
        color: ColorManager.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),

          Text(
            '$greeting,',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 5),

          Row(
            children: [
              Expanded(
                child: Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotificationsScreen(
                        uid: user.uid,
                      ),
                    ),
                  );
                  },
                tooltip: 'Notifications',
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: ColorManager.goldLight,
                  size: 28,
                ),
              ),

              IconButton(
                onPressed: onSettingsTap,
                tooltip: 'Settings',
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Here is your factory overview.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: ColorManager.goldLight,
                size: 15,
              ),
              const SizedBox(width: 8),
              Text(
                '${now.day}/${now.month}/${now.year}',
                style: const TextStyle(
                  color: ColorManager.goldLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
