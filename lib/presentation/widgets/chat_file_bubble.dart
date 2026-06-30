import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../data/models/chat_message_model.dart';

class ChatFileBubble extends StatelessWidget {
  final ChatMessageModel message;
  final VoidCallback? onOpen;

  const ChatFileBubble({
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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.68,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelf ? AppTheme.gold : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:
              isSelf ? null : Border.all(color: AppTheme.warmBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_drive_file_outlined,
              color: isSelf ? Colors.white : AppTheme.textPrimary,
              size: 30,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.fileName ?? '文件',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelf ? Colors.white : AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatSize(message.fileSize),
                    style: TextStyle(
                      color: isSelf
                          ? Colors.white.withValues(alpha: 0.78)
                          : AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSize(int? bytes) {
    if (bytes == null || bytes <= 0) return '未知大小';
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    }
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)}MB';
  }
}
