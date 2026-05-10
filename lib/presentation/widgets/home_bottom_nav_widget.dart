import 'package:flutter/material.dart';
import '../../core/utils/screen_adapter.dart';

class HomeBottomNavWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const HomeBottomNavWidget({super.key, required this.currentIndex, required this.onTap});

  static const _items = [
    ('首页', Icons.home_rounded, 'home'),
    ('社区', Icons.forum_rounded, 'community'),
    ('消息', Icons.message_rounded, 'message'),
    ('我的', Icons.person_rounded, 'profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.h + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(top: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: const Color(0xFF2D2A26).withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (i) {
            final (label, icon, _) = _items[i];
            final selected = currentIndex == i;
            return _buildItem(context, icon: icon, label: label, selected: selected, index: i);
          }),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, {required IconData icon, required String label, required bool selected, required int index}) {
    final color = selected ? const Color(0xFFC4956A) : const Color(0xFFB8A99A);
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(selected ? 6.w : 4.w),
              decoration: selected
                  ? BoxDecoration(color: const Color(0xFFC4956A).withOpacity(0.10), borderRadius: BorderRadius.circular(10.r))
                  : null,
              child: Icon(icon, size: 24.sp, color: color),
            ),
            SizedBox(height: 4.h),
            Text(label, style: TextStyle(
              fontSize: 11.sp, color: color,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            )),
          ],
        ),
      ),
    );
  }
}
