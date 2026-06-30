import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../data/models/chat_message_model.dart';

class ChatVoiceBubble extends StatelessWidget {
  final ChatMessageModel message;
  final VoidCallback? onPlay;
  final bool isPlaying;

  const ChatVoiceBubble({
    super.key,
    required this.message,
    this.onPlay,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSelf = message.isSelf;
    final duration = message.voiceDuration ?? 0;
    return InkWell(
      onTap: onPlay,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minWidth: 112, maxWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelf ? AppTheme.gold : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:
              isSelf ? null : Border.all(color: AppTheme.warmBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: isSelf ? Colors.white : AppTheme.textPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              '$duration"',
              style: TextStyle(
                color: isSelf ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
