import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../data/models/chat_conversation_model.dart';

class ConversationTile extends StatelessWidget {
  final ChatConversationModel conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatarProvider = _avatarProvider;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppTheme.gold.withValues(alpha: 0.16),
        backgroundImage: avatarProvider,
        child: avatarProvider == null
            ? Text(
                conversation.title.isEmpty
                    ? '?'
                    : conversation.title.characters.first,
                style: const TextStyle(color: AppTheme.gold),
              )
            : null,
      ),
      title: Text(
        conversation.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        conversation.lastMessage.isEmpty ? '暂无消息' : conversation.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 13,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: conversation.unreadCount > 0
          ? Container(
              constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.danger,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                conversation.unreadCount > 99
                    ? '99+'
                    : conversation.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
    );
  }

  ImageProvider? get _avatarProvider {
    final url = conversation.faceURL?.trim();
    if (url == null || url.isEmpty) return null;
    return NetworkImage(url);
  }
}
