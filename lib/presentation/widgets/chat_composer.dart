import 'package:flutter/material.dart';

import '../../core/themes/resource.dart';
import 'chat_composer_toolbox.dart';

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
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  late final bool _ownsFocusNode = widget.focusNode == null;
  bool _voiceMode = false;
  bool _recording = false;
  bool _toolsVisible = false;
  bool _sendButtonVisible = false;

  @override
  void initState() {
    super.initState();
    _sendButtonVisible = _controller.text.trim().isNotEmpty;
    _controller.addListener(_handleTextChanged);
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    _focusNode.removeListener(_handleFocusChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleTextChanged() {
    final visible = _controller.text.trim().isNotEmpty;
    if (_sendButtonVisible == visible) return;
    setState(() => _sendButtonVisible = visible);
  }

  void _handleFocusChanged() {
    if (!_focusNode.hasFocus || !_toolsVisible) return;
    setState(() => _toolsVisible = false);
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  void _toggleToolbox() {
    setState(() {
      _toolsVisible = !_toolsVisible;
      _voiceMode = false;
    });
    if (_toolsVisible) {
      _focusNode.unfocus();
    } else {
      _focusNode.requestFocus();
    }
  }

  void _toggleVoiceMode() {
    setState(() {
      _voiceMode = !_voiceMode;
      _toolsVisible = false;
    });
    if (_voiceMode) {
      _focusNode.unfocus();
    } else {
      _focusNode.requestFocus();
    }
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 56),
            color: const Color(0xFFF0F2F6),
            child: Row(
              children: [
                const SizedBox(width: 12),
                _IconAction(
                  icon: _voiceMode
                      ? Icons.keyboard_rounded
                      : Icons.mic_none_rounded,
                  tooltip: _voiceMode ? '\u952e\u76d8' : '\u8bed\u97f3',
                  onTap: _toggleVoiceMode,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _voiceMode ? _buildRecordButton() : _buildTextField(),
                ),
                const SizedBox(width: 12),
                _sendButtonVisible
                    ? _IconAction(
                        icon: Icons.send_rounded,
                        tooltip: '\u53d1\u9001',
                        onTap: _voiceMode ? null : _send,
                      )
                    : _IconAction(
                        icon: Icons.add_circle_outline_rounded,
                        tooltip: '\u66f4\u591a',
                        onTap: _toggleToolbox,
                      ),
                const SizedBox(width: 12),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: offsetAnimation,
                  child: child,
                ),
              );
            },
            child: _toolsVisible
                ? ChatComposerToolbox(
                    key: const ValueKey('chat-composer-toolbox'),
                    items: _toolboxItems,
                  )
                : const SizedBox.shrink(
                    key: ValueKey('chat-composer-toolbox-empty'),
                  ),
          ),
        ],
      ),
    );
  }

  List<ChatComposerToolboxItem> get _toolboxItems {
    return [
      ChatComposerToolboxItem(
        iconAsset: Resource.chatToolboxAlbum,
        label: '\u76f8\u518c',
        onTap: () => _handleToolboxTap(widget.onPickImage),
      ),
      ChatComposerToolboxItem(
        iconAsset: Resource.chatToolboxFile,
        label: '\u6587\u4ef6',
        onTap: () => _handleToolboxTap(widget.onPickFile),
      ),
      ChatComposerToolboxItem(
        iconAsset: Resource.chatToolboxLocation,
        label: '\u4f4d\u7f6e',
        onTap: () => _handleToolboxTap(widget.onSendLocation),
      ),
    ];
  }

  void _handleToolboxTap(VoidCallback? callback) {
    setState(() => _toolsVisible = false);
    callback?.call();
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onLongPressStart: (_) => _startRecord(),
      onLongPressEnd: (_) => _stopRecord(),
      child: Container(
        height: 36,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          _recording ? '\u677e\u5f00\u53d1\u9001' : '\u6309\u4f4f\u8bf4\u8bdd',
          style: const TextStyle(
            color: Color(0xFF0C1C33),
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        minLines: 1,
        maxLines: 4,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => _send(),
        decoration: const InputDecoration(
          hintText: '\u8f93\u5165\u6d88\u606f',
          hintStyle: TextStyle(
            color: Color(0xFF8E9AB0),
            fontSize: 17,
          ),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 8,
          ),
          border: InputBorder.none,
        ),
        style: const TextStyle(
          color: Color(0xFF0C1C33),
          fontSize: 17,
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _IconAction({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Icon(
          icon,
          color: const Color(0xFF0C1C33),
          size: 32,
        ),
      ),
    );
  }
}
