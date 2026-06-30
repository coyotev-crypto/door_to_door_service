import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class ChatTimeLabel extends StatelessWidget {
  final int timestamp;

  const ChatTimeLabel({
    super.key,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.warmBorder.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: Text(
              _formatTime(timestamp),
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(int value) {
    final time = DateTime.fromMillisecondsSinceEpoch(value);
    final now = DateTime.now();
    final isToday =
        time.year == now.year && time.month == now.month && time.day == now.day;
    final minute = time.minute.toString().padLeft(2, '0');
    final hour = time.hour.toString().padLeft(2, '0');

    if (isToday) return '$hour:$minute';

    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    return '${time.year}-$month-$day $hour:$minute';
  }
}
