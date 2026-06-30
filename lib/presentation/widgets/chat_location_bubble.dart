import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../data/models/chat_message_model.dart';

class ChatLocationBubble extends StatelessWidget {
  final ChatMessageModel message;
  final VoidCallback? onOpen;

  const ChatLocationBubble({
    super.key,
    required this.message,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final isSelf = message.isSelf;
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelf ? AppTheme.gold : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:
              isSelf ? null : Border.all(color: AppTheme.warmBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: isSelf ? Colors.white : AppTheme.textPrimary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    message.locationName ?? '位置',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelf ? Colors.white : AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 74,
              decoration: BoxDecoration(
                color: isSelf
                    ? Colors.white.withValues(alpha: 0.22)
                    : AppTheme.creamFill,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.map_outlined,
                  color: isSelf ? Colors.white : AppTheme.textSecondary,
                  size: 34,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
