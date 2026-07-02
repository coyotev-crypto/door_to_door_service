import 'package:flutter/material.dart';

import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/themes/app_theme.dart';
import '../../data/models/chat_message_model.dart';

class ChatTextBubble extends StatelessWidget {
  final ChatMessageModel message;

  const ChatTextBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isSelf = message.isSelf;
    final revoked = message.isRevoked;
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.68,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: revoked
            ? AppTheme.creamFill
            : isSelf
                ? AppTheme.gold
                : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(isSelf ? 12 : 4),
          bottomRight: Radius.circular(isSelf ? 4 : 12),
        ),
        border: revoked || !isSelf
            ? Border.all(color: AppTheme.warmBorder, width: 1)
            : null,
      ),
      child: _LinkedText(
        _content,
        style: TextStyle(
          fontSize: 15,
          height: 1.35,
          fontStyle: revoked ? FontStyle.italic : FontStyle.normal,
          color: revoked
              ? AppTheme.textMuted
              : isSelf
                  ? Colors.white
                  : AppTheme.textPrimary,
        ),
      ),
    );
  }

  String get _content {
    if (message.isRevoked) return message.isSelf ? '你撤回了一条消息' : '对方撤回了一条消息';
    switch (message.type) {
      case ChatMessageType.text:
        return message.text ?? '';
      case ChatMessageType.image:
        return '[图片]';
      case ChatMessageType.video:
        return '[视频]';
      case ChatMessageType.voice:
        return '[语音]';
      case ChatMessageType.file:
        return '[文件]';
      case ChatMessageType.location:
        return '[位置]';
      case ChatMessageType.custom:
      case ChatMessageType.unsupported:
        return message.text?.trim().isNotEmpty == true
            ? message.text!.trim()
            : '[暂不支持的消息]';
    }
  }
}

class _LinkedText extends StatefulWidget {
  static final _pattern = RegExp(
    r'((https?:\/\/)?([\w-]+\.)+[\w-]{2,}(\/[^\s]*)?)|([\w.+-]+@[\w-]+(\.[\w-]+)+)|(\b1[3-9]\d{9}\b)',
    caseSensitive: false,
  );

  final String text;
  final TextStyle style;

  const _LinkedText(
    this.text, {
    required this.style,
  });

  @override
  State<_LinkedText> createState() => _LinkedTextState();
}

class _LinkedTextState extends State<_LinkedText> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();

    final spans = <TextSpan>[];
    var start = 0;
    for (final match in _LinkedText._pattern.allMatches(widget.text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: widget.text.substring(start, match.start)));
      }
      final value = widget.text.substring(match.start, match.end);
      final recognizer = TapGestureRecognizer()..onTap = () => _open(value);
      _recognizers.add(recognizer);
      spans.add(
        TextSpan(
          text: value,
          style: widget.style.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: widget.style.color,
          ),
          recognizer: recognizer,
        ),
      );
      start = match.end;
    }
    if (start < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(start)));
    }
    return RichText(text: TextSpan(style: widget.style, children: spans));
  }

  Future<void> _open(String value) async {
    final uri = _uriFor(value);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Uri? _uriFor(String value) {
    if (value.contains('@') && !value.startsWith('http')) {
      return Uri(scheme: 'mailto', path: value);
    }
    if (RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
      return Uri(scheme: 'tel', path: value);
    }
    final normalized =
        value.startsWith('http://') || value.startsWith('https://')
            ? value
            : 'https://$value';
    return Uri.tryParse(normalized);
  }
}
