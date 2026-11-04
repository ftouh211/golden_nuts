
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:golds_nuts/core/utils/color_manager.dart';

class NotificationsScreen extends StatelessWidget {
  final String uid;

  const NotificationsScreen({
    super.key,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: ColorManager.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('receiverId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _NotificationMessage(
              icon: Icons.error_outline,
              message: 'Something went wrong',
              subtitle: 'Could not load notifications.',
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: ColorManager.primary,
              ),
            );
          }

          final documents = snapshot.data?.docs ?? [];

          documents.sort((a, b) {
            final aDate = a.data()['createdAt'] as Timestamp?;
            final bDate = b.data()['createdAt'] as Timestamp?;

            return (bDate?.millisecondsSinceEpoch ?? 0)
                .compareTo(aDate?.millisecondsSinceEpoch ?? 0);
          });

          if (documents.isEmpty) {
            return const _NotificationMessage(
              icon: Icons.notifications_none_rounded,
              message: 'No notifications yet',
              subtitle: 'You will see your updates here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: documents.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final document = documents[index];
              final data = document.data();

              final title = data['title'] as String? ?? 'Notification';
              final body = data['body'] as String? ?? '';
              final isRead = data['isRead'] as bool? ?? false;
              final timestamp = data['createdAt'] as Timestamp?;

              return _NotificationCard(
                title: title,
                body: body,
                isRead: isRead,
                date: timestamp?.toDate(),
                onTap: () async {
                  if (isRead) return;

                  try {
                    await document.reference.update({
                      'isRead': true,
                    });
                  } catch (_) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not update notification.'),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String body;
  final bool isRead;
  final DateTime? date;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.title,
    required this.body,
    required this.isRead,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isRead ? ColorManager.surface : ColorManager.primary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorManager.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ColorManager.gold.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: ColorManager.gold,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: ColorManager.textPrimary,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: ColorManager.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      body,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: ColorManager.textSecondary,
                      ),
                    ),
                    if (date != null) ...[
                      const SizedBox(height: 9),
                      Text(
                        _formatDate(date!),
                        style: const TextStyle(
                          fontSize: 11,
                          color: ColorManager.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    return '${localDate.day}/${localDate.month}/${localDate.year}'
        '  ${localDate.hour.toString().padLeft(2, '0')}:'
        '${localDate.minute.toString().padLeft(2, '0')}';
  }
}

class _NotificationMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subtitle;

  const _NotificationMessage({
    required this.icon,
    required this.message,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 65,
              color: ColorManager.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: ColorManager.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: ColorManager.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
