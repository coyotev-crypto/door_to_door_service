import 'package:flutter/material.dart';
import 'common_dropdowm_selector.dart';

/// 证书等级选择器组件（基于通用选择器的便捷封装）
class CertificateLevelSelector extends StatelessWidget {
  /// 选中的证书等级
  final String? selectedLevel;

  /// 证书等级改变回调
  final Function(String?) onLevelChanged;

  const CertificateLevelSelector({
    super.key,
    required this.selectedLevel,
    required this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CommonDropdownSelector<String>(
      label: '证书等级',
      selectedValue: selectedLevel,
      onValueChanged: onLevelChanged,
      hintText: '请选择证书等级',
      items: const [
        DropdownMenuItem(
          value: '初级',
          child: Text('初级'),
        ),
        DropdownMenuItem(
          value: '中级',
          child: Text('中级'),
        ),
        DropdownMenuItem(
          value: '高级',
          child: Text('高级'),
        ),
        DropdownMenuItem(
          value: '专家',
          child: Text('专家'),
        ),
      ],
    );
  }
}
