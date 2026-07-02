import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/themes/app_theme.dart';
import '../../data/models/chat_message_model.dart';

class ChatVideoBubble extends StatelessWidget {
  final ChatMessageModel message;

  const ChatVideoBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openVideo,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.creamFill,
            border: Border.all(color: AppTheme.warmBorder),
          ),
          child: SizedBox(
            width: 156,
            height: 156,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildCover(),
                const Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                ),
                if (message.videoDuration != null)
                  Positioned(
                    right: 8,
                    bottom: 6,
                    child: Text(
                      _durationText(message.videoDuration!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    final localPath = message.videoSnapshotLocalPath;
    if (localPath != null && localPath.isNotEmpty) {
      final file = File(localPath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover, errorBuilder: _error);
      }
    }

    final url = message.videoSnapshotUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(url, fit: BoxFit.cover, errorBuilder: _error);
    }

    return _placeholder;
  }

  Widget _error(BuildContext context, Object error, StackTrace? stackTrace) {
    return _placeholder;
  }

  Widget get _placeholder {
    return const Center(
      child: Icon(
        Icons.videocam_off_outlined,
        color: AppTheme.textMuted,
      ),
    );
  }

  Future<void> _openVideo() async {
    final localPath = message.videoLocalPath;
    if (localPath != null && localPath.isNotEmpty && File(localPath).existsSync()) {
      await OpenFilex.open(localPath);
      return;
    }

    final url = message.videoUrl;
    final uri = url == null ? null : Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _durationText(int duration) {
    final seconds = duration > 1000 ? duration ~/ 1000 : duration;
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '$minutes:${rest.toString().padLeft(2, '0')}';
  }
}
