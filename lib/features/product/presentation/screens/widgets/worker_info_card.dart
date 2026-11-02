import 'package:flutter/material.dart';
import 'package:golds_nuts/features/auth/domain/entities/user_entity.dart';

class WorkerInfoCard extends StatelessWidget {
  final UserEntity worker;
  final VoidCallback onTap;

  const WorkerInfoCard({
    super.key,
    required this.worker,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                child: Text(
                  worker.name.isNotEmpty
                      ? worker.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      worker.email,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          worker.isActive
                              ? Icons.check_circle
                              : Icons.block,
                          size: 15,
                          color: worker.isActive
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          worker.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 12,
                            color: worker.isActive
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(Icons.more_vert),
            ],
          ),
        ),
      ),
    );
  }
}