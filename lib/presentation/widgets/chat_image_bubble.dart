import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../data/models/chat_message_model.dart';
import '../screens/chat/chat_image_preview_screen.dart';

class ChatImageBubble extends StatelessWidget {
  final ChatMessageModel message;

  const ChatImageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final image = _buildImage();
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatImagePreviewScreen(message: message),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.creamFill,
            border: Border.all(color: AppTheme.warmBorder),
          ),
          child: SizedBox(
            width: _displaySize.width,
            height: _displaySize.height,
            child: image,
          ),
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
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder,
        );
      }
    }

    final url = message.imageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    }

    return _placeholder;
  }

  Widget get _placeholder {
    return const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppTheme.textMuted,
      ),
    );
  }

  Size get _displaySize {
    final width = message.imageWidth;
    final height = message.imageHeight;
    if (width == null || height == null || width <= 0 || height <= 0) {
      return const Size(156, 156);
    }

    const maxSide = 180.0;
    const minSide = 96.0;
    final ratio = width / height;
    if (ratio >= 1) {
      const displayWidth = maxSide;
      final displayHeight = (displayWidth / ratio).clamp(minSide, maxSide);
      return Size(displayWidth, displayHeight.toDouble());
    }

    const displayHeight = maxSide;
    final displayWidth = (displayHeight * ratio).clamp(minSide, maxSide);
    return Size(displayWidth.toDouble(), displayHeight);
  }
}
