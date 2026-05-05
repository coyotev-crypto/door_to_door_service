import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'primary_input_field.dart';

/// 手机号输入框
///
/// 基于CommonInputField实现的专用手机号输入框
class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? Function(String?)? validator;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.hintText = '请输入手机号',
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryInputField(
      controller: controller,
      hintText: hintText,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      validator: validator,
    );
  }
}
