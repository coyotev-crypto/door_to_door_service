import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class ChatComposer extends StatefulWidget {
  final ValueChanged<String> onSend;
  final VoidCallback? onPickImage;
  final VoidCallback? onPickFile;
  final VoidCallback? onSendLocation;
  final Future<void> Function()? onStartRecord;
  final Future<void> Function()? onStopRecord;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const ChatComposer({
    super.key,
    required this.onSend,
    this.onPickImage,
    this.onPickFile,
    this.onSendLocation,
    this.onStartRecord,
    this.onStopRecord,
    this.controller,
    this.focusNode,
  });

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  late final bool _ownsController = widget.controller == null;
  bool _voiceMode = false;
  bool _recording = false;

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  Future<void> _startRecord() async {
    if (widget.onStartRecord == null) return;
    setState(() => _recording = true);
    await widget.onStartRecord?.call();
  }

  Future<void> _stopRecord() async {
    if (!_recording) return;
    await widget.onStopRecord?.call();
    if (mounted) {
      setState(() => _recording = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.warmBorder)),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _voiceMode = !_voiceMode),
              icon: Icon(_voiceMode ? Icons.keyboard_rounded : Icons.mic_none),
              color: AppTheme.textSecondary,
              tooltip: _voiceMode ? '键盘' : '语音',
            ),
            Expanded(
              child: _voiceMode ? _buildRecordButton() : _buildTextField(),
            ),
            PopupMenuButton<_MoreAction>(
              icon: const Icon(Icons.add_circle_outline_rounded),
              color: Colors.white,
              tooltip: '更多',
              onSelected: (action) {
                switch (action) {
                  case _MoreAction.image:
                    widget.onPickImage?.call();
                    break;
                  case _MoreAction.file:
                    widget.onPickFile?.call();
                    break;
                  case _MoreAction.location:
                    widget.onSendLocation?.call();
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _MoreAction.image,
                  child: ListTile(
                    leading: Icon(Icons.image_outlined),
                    title: Text('图片'),
                  ),
                ),
                PopupMenuItem(
                  value: _MoreAction.file,
                  child: ListTile(
                    leading: Icon(Icons.insert_drive_file_outlined),
                    title: Text('文件'),
                  ),
                ),
                PopupMenuItem(
                  value: _MoreAction.location,
                  child: ListTile(
                    leading: Icon(Icons.location_on_outlined),
                    title: Text('位置'),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            IconButton.filled(
              onPressed: _voiceMode ? null : _send,
              icon: const Icon(Icons.send_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onLongPressStart: (_) => _startRecord(),
      onLongPressEnd: (_) => _stopRecord(),
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _recording ? AppTheme.warmBorder : AppTheme.creamFill,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _recording ? '松开发送' : '按住说话',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      minLines: 1,
      maxLines: 4,
      textInputAction: TextInputAction.send,
      onSubmitted: (_) => _send(),
      decoration: InputDecoration(
        hintText: '输入消息',
        isDense: true,
        filled: true,
        fillColor: AppTheme.creamFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

enum _MoreAction {
  image,
  file,
  location,
}
