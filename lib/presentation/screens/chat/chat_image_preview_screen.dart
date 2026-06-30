import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/themes/app_theme.dart';
import '../../../data/models/chat_message_model.dart';

class ChatImagePreviewScreen extends StatelessWidget {
  final ChatMessageModel message;

  const ChatImagePreviewScreen({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final localPath = message.imageLocalPath;
    if (localPath != null && localPath.isNotEmpty) {
      final file = File(localPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _placeholder,
        );
      }
    }

    final url = message.imageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _placeholder,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const CircularProgressIndicator(color: Colors.white);
        },
      );
    }

    return _placeholder;
  }

  Widget get _placeholder {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.broken_image_outlined,
          color: AppTheme.textMuted,
          size: 42,
        ),
        SizedBox(height: 8),
        Text(
          '图片加载失败',
          style: TextStyle(color: AppTheme.textMuted),
        ),
      ],
    );
  }
}
