import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/screen_adapter.dart';
import '../../core/themes/app_theme.dart';

/// 通用 AppBar — 温润质感风格
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool showBackButton;

  const CommonAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title,
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary)),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  size: 20.sp, color: AppTheme.textPrimary),
              onPressed: onBack ?? () => Get.back(),
            )
          : null,
      automaticallyImplyLeading: showBackButton,
      actions: actions,
    );
  }
}
