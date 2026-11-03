import 'package:flutter/material.dart';
import 'package:golds_nuts/core/utils/color_manager.dart';

class DashboardHeader extends StatelessWidget {
  final String managerName;

  const DashboardHeader({super.key, required this.managerName});

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

          Text(
            managerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
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
