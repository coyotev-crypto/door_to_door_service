import 'package:flutter/material.dart';

import '../../data/models/chat_message_model.dart';
import 'chat_text_bubble.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessageModel message;

  const ChatMessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ChatTextBubble(message: message);
  }
}
