import 'package:flutter/material.dart';
import '../../core/utils/screen_adapter.dart';

class HomeBottomNavWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const HomeBottomNavWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              icon: Icons.home_rounded,
              label: '首页',
              index: 0,
              isSelected: currentIndex == 0,
            ),
            _buildNavItem(
              context,
              icon: Icons.category_rounded,
              label: '分类',
              index: 1,
              isSelected: currentIndex == 1,
            ),
            _buildNavItem(
              context,
              icon: Icons.message_rounded,
              label: '消息',
              index: 2,
              isSelected: currentIndex == 2,
            ),
            _buildNavItem(
              context,
              icon: Icons.person_rounded,
              label: '我的',
              index: 3,
              isSelected: currentIndex == 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    final color = isSelected
        ? Theme.of(context).primaryColor
        : Colors.grey[600];

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: color,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
