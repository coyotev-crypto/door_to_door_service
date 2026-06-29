import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../data/models/chat_message_model.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessageModel message;

  const ChatMessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isSelf = message.isSelf;
    return Align(
      alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          crossAxisAlignment:
              isSelf ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelf ? AppTheme.gold : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isSelf ? 12 : 4),
                  bottomRight: Radius.circular(isSelf ? 4 : 12),
                ),
                border: isSelf
                    ? null
                    : Border.all(color: AppTheme.warmBorder, width: 1),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: isSelf ? Colors.white : AppTheme.textPrimary,
                ),
              ),
            ),
            if (message.isSending || message.isSendFailed)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  message.isSendFailed ? '发送失败' : '发送中',
                  style: TextStyle(
                    fontSize: 11,
                    color: message.isSendFailed
                        ? AppTheme.danger
                        : AppTheme.textMuted,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
