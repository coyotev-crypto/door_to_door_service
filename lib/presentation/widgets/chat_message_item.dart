import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../data/models/chat_message_model.dart';
import 'chat_file_bubble.dart';
import 'chat_image_bubble.dart';
import 'chat_location_bubble.dart';
import 'chat_message_action_sheet.dart';
import 'chat_send_status_view.dart';
import 'chat_text_bubble.dart';
import 'chat_time_label.dart';
import 'chat_voice_bubble.dart';

class ChatMessageItem extends StatelessWidget {
  final ChatMessageModel message;
  final ChatMessageModel? previousMessage;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;
  final VoidCallback? onRetry;
  final VoidCallback? onRevoke;
  final VoidCallback? onPlayVoice;
  final VoidCallback? onOpenFile;
  final VoidCallback? onOpenLocation;

  const ChatMessageItem({
    super.key,
    required this.message,
    this.previousMessage,
    this.onCopy,
    this.onDelete,
    this.onRetry,
    this.onRevoke,
    this.onPlayVoice,
    this.onOpenFile,
    this.onOpenLocation,
  });

  @override
  Widget build(BuildContext context) {
    final showTime = previousMessage == null ||
        (previousMessage!.sendTime - message.sendTime).abs() > 5 * 60 * 1000;

    return Column(
      children: [
        if (showTime) ChatTimeLabel(timestamp: message.sendTime),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                message.isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!message.isSelf) _Avatar(label: _avatarLabel),
              if (!message.isSelf) const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: message.isSelf
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onLongPress: () => _showActionSheet(context),
                      child: _buildBubble(),
                    ),
                    const SizedBox(height: 4),
                    ChatSendStatusView(
                      message: message,
                      onRetry: onRetry,
                    ),
                  ],
                ),
              ),
              if (message.isSelf) const SizedBox(width: 8),
              if (message.isSelf) _Avatar(label: _avatarLabel),
            ],
          ),
        ),
      ],
    );
  }

  String get _avatarLabel {
    final name = message.rawMessage.senderNickname?.trim();
    if (name != null && name.isNotEmpty) return name.characters.first;
    final id = message.sendID.trim();
    if (id.isNotEmpty) return id.characters.first.toUpperCase();
    return '?';
  }

  Widget _buildBubble() {
    if (message.isRevoked) {
      return ChatTextBubble(message: message);
    }
    if (message.type == ChatMessageType.image) {
      return ChatImageBubble(message: message);
    }
    if (message.type == ChatMessageType.voice) {
      return ChatVoiceBubble(
        message: message,
        onPlay: onPlayVoice,
      );
    }
    if (message.type == ChatMessageType.file) {
      return ChatFileBubble(
        message: message,
        onOpen: onOpenFile,
      );
    }
    if (message.type == ChatMessageType.location) {
      return ChatLocationBubble(
        message: message,
        onOpen: onOpenLocation,
      );
    }
    return ChatTextBubble(message: message);
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: false,
      builder: (_) => ChatMessageActionSheet(
        message: message,
        onCopy: onCopy,
        onDelete: onDelete,
        onRetry: onRetry,
        onRevoke: onRevoke,
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String label;

  const _Avatar({required this.label});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppTheme.warmBorder,
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
