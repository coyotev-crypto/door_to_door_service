import 'package:dtd/core/utils/log_util.dart';
import 'package:flutter/material.dart';
import 'package:shengwang_chat_uikit/provider/chat_uikit_profile.dart';
import 'package:shengwang_chat_uikit/ui/views/messages_view.dart';

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

  @override
  Widget build(BuildContext context) {
    return MessagesView(
      profile: ChatUIKitProfile.contact(
        id: widget.userId,
      ),
      onAvatarTap:  (context, model) {
        LogUtil.d('onAvatarTap');
        return null;
      },
    );
  }
}
