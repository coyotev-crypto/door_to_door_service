import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/themes/app_theme.dart';
import '../../data/models/chat_message_model.dart';
import 'chat_message_item.dart';

class ChatMessageList extends StatelessWidget {
  final RxList<ChatMessageModel> messages;
  final ScrollController scrollController;
  final RxBool isLoadingMore;
  final RxBool showNewMessageIndicator;
  final Future<void> Function() onRefresh;
  final ValueChanged<ChatMessageModel> onCopy;
  final ValueChanged<ChatMessageModel> onDelete;
  final ValueChanged<ChatMessageModel> onRetry;
  final ValueChanged<ChatMessageModel> onRevoke;
  final ValueChanged<ChatMessageModel> onPlayVoice;
  final ValueChanged<ChatMessageModel> onOpenFile;
  final ValueChanged<ChatMessageModel> onOpenLocation;
  final VoidCallback onJumpToBottom;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.isLoadingMore,
    required this.showNewMessageIndicator,
    required this.onRefresh,
    required this.onCopy,
    required this.onDelete,
    required this.onRetry,
    required this.onRevoke,
    required this.onPlayVoice,
    required this.onOpenFile,
    required this.onOpenLocation,
    required this.onJumpToBottom,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: onRefresh,
          child: Obx(
            () => ListView.builder(
              controller: scrollController,
              reverse: true,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: messages.length + (isLoadingMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                final message = messages[index];
                final previous =
                    index + 1 < messages.length ? messages[index + 1] : null;
                return ChatMessageItem(
                  message: message,
                  previousMessage: previous,
                  onCopy: () => onCopy(message),
                  onDelete: () => onDelete(message),
                  onRetry: () => onRetry(message),
                  onRevoke: () => onRevoke(message),
                  onPlayVoice: () => onPlayVoice(message),
                  onOpenFile: () => onOpenFile(message),
                  onOpenLocation: () => onOpenLocation(message),
                );
              },
            ),
          ),
        ),
        Obx(
          () => showNewMessageIndicator.value
              ? Positioned(
                  right: 16,
                  bottom: 16,
                  child: FilledButton(
                    onPressed: onJumpToBottom,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('新消息'),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
