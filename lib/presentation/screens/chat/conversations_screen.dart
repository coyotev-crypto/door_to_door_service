import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shengwang_chat_uikit/ui/models/conversation_item_model.dart';
import 'package:shengwang_chat_uikit/ui/views/conversations_view.dart';
import '../../../routes/route_names.dart';
import '../../widgets/common_app_bar.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '聊天', showBackButton: false),
      body: ConversationsView(
        enableAppBar: false,
        enableSearchBar: false,
        onItemTap:  (BuildContext context, ConversationItemModel info){
          Get.toNamed(
            RouteNames.chatDetail,
            parameters: {'userId': info.profile.id},
          );
        }
      ),
    );
  }
}
