import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../data/models/chat_message_model.dart';

class ChatTextBubble extends StatelessWidget {
  final ChatMessageModel message;

  const ChatTextBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isSelf = message.isSelf;
    final revoked = message.isRevoked;
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.68,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: revoked
            ? AppTheme.creamFill
            : isSelf
                ? AppTheme.gold
                : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(isSelf ? 12 : 4),
          bottomRight: Radius.circular(isSelf ? 4 : 12),
        ),
        border: revoked || !isSelf
            ? Border.all(color: AppTheme.warmBorder, width: 1)
            : null,
      ),
      child: Text(
        _content,
        style: TextStyle(
          fontSize: 15,
          height: 1.35,
          fontStyle: revoked ? FontStyle.italic : FontStyle.normal,
          color: revoked
              ? AppTheme.textMuted
              : isSelf
                  ? Colors.white
                  : AppTheme.textPrimary,
        ),
      ),
    );
  }

  String get _content {
    if (message.isRevoked) return message.isSelf ? '你撤回了一条消息' : '对方撤回了一条消息';
    switch (message.type) {
      case ChatMessageType.text:
        return message.text ?? '';
      case ChatMessageType.image:
        return '[图片]';
      case ChatMessageType.voice:
        return '[语音]';
      case ChatMessageType.file:
        return '[文件]';
      case ChatMessageType.location:
        return '[位置]';
      case ChatMessageType.custom:
      case ChatMessageType.unsupported:
        return '[暂不支持的消息]';
    }
  }
}
