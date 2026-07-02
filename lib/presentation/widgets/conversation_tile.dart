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
    return Ink(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 68,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.gold.withValues(alpha: 0.16),
                  backgroundImage: avatarProvider,
                  child: avatarProvider == null
                      ? Text(
                          conversation.title.isEmpty
                              ? '?'
                              : conversation.title.characters.first,
                          style: const TextStyle(
                            color: AppTheme.gold,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF0C1C33),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            conversation.timeText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8E9AB0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessage.isEmpty
                                  ? '暂无消息'
                                  : conversation.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8E9AB0),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _UnreadBadge(count: conversation.unreadCount),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider? get _avatarProvider {
    final url = conversation.faceURL?.trim();
    if (url == null || url.isEmpty) return null;
    return NetworkImage(url);
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;

  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox(width: 18, height: 18);
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFF381F),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          height: 1,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
