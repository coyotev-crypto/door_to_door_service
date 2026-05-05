import 'package:flutter/material.dart';
import 'chat_detail_widget.dart';

/// 聊天详情页面
class ChatDetailScreen extends StatelessWidget {
  final String conversationId;
  final String? userName;
  final String? userAvatar;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    this.userName,
    this.userAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return ChatDetailWidget(
      conversationId: conversationId,
      userName: userName,
      userAvatar: userAvatar,
    );
  }
}
