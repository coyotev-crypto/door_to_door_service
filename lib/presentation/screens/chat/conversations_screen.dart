import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/conversation_controller.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/conversation_tile.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ConversationController>()
        ? Get.find<ConversationController>()
        : Get.put(ConversationController());

    return Scaffold(
      appBar: const CommonAppBar(title: '聊天', showBackButton: false),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final conversations = controller.conversations;
          if (conversations.isEmpty) {
            return const Center(child: Text('暂无会话'));
          }

          return RefreshIndicator(
            onRefresh: controller.loadFirstPage,
            child: ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return ConversationTile(
                  conversation: conversation,
                  onTap: () => controller.toChat(conversation),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
