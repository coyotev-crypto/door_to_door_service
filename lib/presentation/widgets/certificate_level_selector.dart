import 'package:flutter/material.dart';
import '../../../core/utils/screen_adapter.dart';

/// 证书等级选择器组件
class CertificateLevelSelector extends StatelessWidget {
  final String? selectedLevel;
  final Function(String?) onLevelChanged;

  static const _levels = ['初级', '中级', '高级', '专家'];

  const CertificateLevelSelector({
    super.key,
    required this.selectedLevel,
    required this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '证书等级',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 56.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                value: selectedLevel,
                isExpanded: true,
                hint: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    '请选择证书等级',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                icon: Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: primaryColor,
                    size: 24.sp,
                  ),
                ),
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black87,
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                iconSize: 24.sp,
                underline: const SizedBox(),
                items: _levels
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Text(level),
                          ),
                        ))
                    .toList(),
                onChanged: onLevelChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
