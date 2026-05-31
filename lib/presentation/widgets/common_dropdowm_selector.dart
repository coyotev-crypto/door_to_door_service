import 'package:flutter/material.dart';
import '../../../core/utils/screen_adapter.dart';

/// 通用下拉选择器组件
class CommonDropdownSelector<T> extends StatelessWidget {
  /// 选择器标签
  final String label;

  /// 选中的值
  final T? selectedValue;

  /// 值改变回调
  final Function(T?) onValueChanged;

  /// 提示文本
  final String? hintText;

  /// 下拉选项列表
  final List<DropdownMenuItem<T>> items;

  /// 是否显示边框
  final bool showBorder;

  /// 边框颜色
  final Color? borderColor;

  /// 背景颜色
  final Color? backgroundColor;

  /// 下拉图标
  final Widget? icon;

  /// 是否禁用
  final bool enabled;

  const CommonDropdownSelector({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.onValueChanged,
    required this.items,
    this.hintText,
    this.showBorder = true,
    this.borderColor,
    this.backgroundColor,
    this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标签
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),

        // 下拉选择器
        Container(
          decoration: BoxDecoration(
            color:
                enabled ? (backgroundColor ?? Colors.white) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12.r),
            border: showBorder
                ? Border.all(
                    color: borderColor ??
                        (selectedValue != null
                            ? Colors.grey[200]!
                            : Colors.transparent),
                    width: 1.5,
                  )
                : null,
            boxShadow: enabled && selectedValue != null
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<T>(
                value: selectedValue,
                isExpanded: true,
                hint: hintText != null
                    ? Text(
                        hintText!,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[400],
                        ),
                      )
                    : null,
                icon: icon ??
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: enabled ? primaryColor : Colors.grey[400],
                      size: 24.sp,
                    ),
                style: TextStyle(
                  fontSize: 16.sp,
                  color: enabled
                      ? (selectedValue != null
                          ? Colors.black87
                          : Colors.grey[400])
                      : Colors.grey[400],
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                iconSize: 24.sp,
                underline: const SizedBox(),
                items: items,
                onChanged: enabled ? onValueChanged : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
