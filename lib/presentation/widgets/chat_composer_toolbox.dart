import 'package:flutter/material.dart';

class ChatComposerToolboxItem {
  final String iconAsset;
  final String label;
  final VoidCallback? onTap;

  const ChatComposerToolboxItem({
    required this.iconAsset,
    required this.label,
    this.onTap,
  });
}

class ChatComposerToolbox extends StatelessWidget {
  final List<ChatComposerToolboxItem> items;

  const ChatComposerToolbox({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 224,
      color: const Color(0xFFF0F2F6),
      child: GridView.builder(
        itemCount: items.length,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 78 / 105,
          crossAxisSpacing: 10,
          mainAxisSpacing: 2,
        ),
        itemBuilder: (_, index) {
          final item = items[index];
          return _ToolboxItem(item: item);
        },
      ),
    );
  }
}

class _ToolboxItem extends StatelessWidget {
  final ChatComposerToolboxItem item;

  const _ToolboxItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: item.onTap,
      child: Column(
        children: [
          Image.asset(
            item.iconAsset,
            width: 58,
            height: 58,
          ),
          const SizedBox(height: 10),
          Text(
            item.label,
            style: const TextStyle(
              color: Color(0xFF0C1C33),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
