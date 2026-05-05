import 'package:flutter/material.dart';
import '../../core/utils/screen_adapter.dart';

/// 性别选择器组件
///
/// 用于选择用户性别的单选组件
class GenderSelector extends StatelessWidget {
  /// 当前选中的性别值
  final String? selectedGender;

  /// 性别改变回调
  final Function(String?)? onGenderChanged;

  const GenderSelector({
    super.key,
    this.selectedGender,
    this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '性别',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                context: context,
                label: '男',
                value: 'male',
                isSelected: selectedGender == 'male',
                onTap: () => onGenderChanged?.call('male'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildGenderOption(
                context: context,
                label: '女',
                value: 'female',
                isSelected: selectedGender == 'female',
                onTap: () => onGenderChanged?.call('female'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建性别选项
  ///
  /// [context] 上下文
  /// [label] 选项标签
  /// [value] 选项值
  /// [isSelected] 是否选中
  /// [onTap] 点击回调
  Widget _buildGenderOption({
    required BuildContext context,
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: isSelected ? value : null,
              onChanged: (_) => onTap(),
              activeColor: Theme.of(context).primaryColor,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
