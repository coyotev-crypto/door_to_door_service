import 'package:flutter/material.dart';

import '../../data/models/chat_message_model.dart';

class ChatMessageActionSheet extends StatelessWidget {
  final ChatMessageModel message;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;
  final VoidCallback? onRetry;
  final VoidCallback? onRevoke;

  const ChatMessageActionSheet({
    super.key,
    required this.message,
    this.onCopy,
    this.onDelete,
    this.onRetry,
    this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    final canRevoke = message.isSelf &&
        !message.isRevoked &&
        !message.isSendFailed &&
        !message.isSending;
    final actions = <Widget>[
      if (message.type == ChatMessageType.text && !message.isRevoked)
        _ActionTile(
          icon: Icons.copy_rounded,
          label: '复制',
          onTap: () {
            Navigator.of(context).pop();
            onCopy?.call();
          },
        ),
      if (message.isSendFailed)
        _ActionTile(
          icon: Icons.refresh_rounded,
          label: '重发',
          onTap: () {
            Navigator.of(context).pop();
            onRetry?.call();
          },
        ),
      if (canRevoke)
        _ActionTile(
          icon: Icons.undo_rounded,
          label: '撤回',
          onTap: () {
            Navigator.of(context).pop();
            onRevoke?.call();
          },
        ),
      _ActionTile(
        icon: Icons.delete_outline_rounded,
        label: '删除',
        isDanger: true,
        onTap: () {
          Navigator.of(context).pop();
          onDelete?.call();
        },
      ),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ...actions,
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? Colors.redAccent : Colors.black87;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color),
      ),
      onTap: onTap,
    );
  }
}
