import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../data/models/chat_message_model.dart';

class ChatSendStatusView extends StatelessWidget {
  final ChatMessageModel message;
  final VoidCallback? onRetry;

  const ChatSendStatusView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isSendFailed) {
      return InkWell(
        onTap: onRetry,
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            '发送失败，点击重试',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.danger,
            ),
          ),
        ),
      );
    }

    if (message.isSending) {
      return const Text(
        '发送中',
        style: TextStyle(
          fontSize: 11,
          color: AppTheme.textMuted,
        ),
      );
    }

    if (message.isSelf) {
      return Text(
        message.isRead ? '已读' : '未读',
        style: const TextStyle(
          fontSize: 11,
          color: AppTheme.textMuted,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
