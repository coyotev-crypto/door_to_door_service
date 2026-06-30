import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/chat_detail_controller.dart';
import '../../widgets/chat_composer.dart';
import '../../widgets/chat_message_list.dart';
import '../../widgets/common_app_bar.dart';

class ChatDetailScreen extends StatefulWidget {
  final String userId;

  const ChatDetailScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late final ChatDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      ChatDetailController(
        userID: widget.userId,
        initialConversationID: Get.arguments?['conversationID']?.toString(),
      ),
      tag: widget.userId,
    );
  }

  @override
  void dispose() {
    Get.delete<ChatDetailController>(tag: widget.userId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: CommonAppBar(title: _controller.title.value),
        body: Column(
          children: [
            Expanded(
              child: Obx(
                () {
                  if (_controller.isInitialLoading.value &&
                      _controller.messages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_controller.errorMessage.value.isNotEmpty &&
                      _controller.messages.isEmpty) {
                    return Center(
                      child: Text(_controller.errorMessage.value),
                    );
                  }

                  final messages = _controller.messages;
                  if (messages.isEmpty) {
                    return const Center(child: Text('暂无消息'));
                  }

                  return ChatMessageList(
                    messages: _controller.messages,
                    scrollController: _controller.scrollController,
                    isLoadingMore: _controller.isLoadingMore,
                    showNewMessageIndicator:
                        _controller.showNewMessageIndicator,
                    onCopy: _controller.copyMessage,
                    onDelete: _controller.deleteLocalMessage,
                    onRetry: _controller.retryMessage,
                    onRevoke: _controller.revokeMessage,
                    onPlayVoice: _controller.playVoice,
                    onOpenFile: _controller.openFile,
                    onOpenLocation: _controller.openLocation,
                    onJumpToBottom: _controller.scrollToBottom,
                  );
                },
              ),
            ),
            ChatComposer(
              controller: _controller.inputController,
              focusNode: _controller.focusNode,
              onSend: _controller.sendText,
              onPickImage: _controller.pickAndSendImage,
              onPickFile: _controller.pickAndSendFile,
              onSendLocation: _controller.sendCurrentLocation,
              onStartRecord: _controller.startRecordVoice,
              onStopRecord: _controller.stopRecordAndSendVoice,
            ),
          ],
        ),
      ),
    );
  }
}
