import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/chat_detail_controller.dart';
import '../../widgets/chat_composer.dart';
import '../../widgets/chat_message_bubble.dart';
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
                  if (_controller.isLoading.value &&
                      _controller.messages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = _controller.messages;
                  if (messages.isEmpty) {
                    return const Center(child: Text('暂无消息'));
                  }

                  return RefreshIndicator(
                    onRefresh: () => _controller.loadHistory(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return ChatMessageBubble(message: messages[index]);
                      },
                    ),
                  );
                },
              ),
            ),
            ChatComposer(onSend: _controller.sendText),
          ],
        ),
      ),
    );
  }
}
