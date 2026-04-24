import 'package:flutter/material.dart';
import '../../core/utils/screen_adapter.dart';

/// 空状态占位图组件
class EmptyPlaceholderWidget extends StatelessWidget {
  /// 显示的消息文本
  final String message;

  /// 图标
  final IconData? icon;

  /// 图标大小
  final double? iconSize;

  /// 图标颜色
  final Color? iconColor;

  /// 消息文本样式
  final TextStyle? messageStyle;

  /// 顶部内边距
  final double? verticalPadding;

  /// 是否限制高度（防止溢出）
  final bool constrainHeight;

  const EmptyPlaceholderWidget({
    super.key,
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.iconSize,
    this.iconColor,
    this.messageStyle,
    this.verticalPadding,
    this.constrainHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: iconSize ?? 80.sp,
          color: iconColor ?? Colors.grey[300],
        ),
        SizedBox(height: 16.h),
        Text(
          message,
          style: messageStyle ?? TextStyle(
            fontSize: 16.sp,
            color: Colors.grey[500],
          ),
        ),
      ],
    );

    if (constrainHeight) {
      return SizedBox(
        height: 300.h,
        child: Center(child: content),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: verticalPadding ?? 60.h),
      child: Center(child: content),
    );
  }
}
