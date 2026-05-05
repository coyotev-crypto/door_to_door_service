import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/screen_adapter.dart';

/// 通用输入框组件
class PrimaryInputField extends StatefulWidget {
  // 改为 StatefulWidget 以获取布局信息
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final Function(String)? onChanged;
  final Function()? onTap;
  final bool readOnly;
  final TextAlign textAlign;
  final Widget? trailingButton;
  final AutovalidateMode? autovalidateMode;

  const PrimaryInputField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.textAlign = TextAlign.start,
    this.trailingButton,
    this.autovalidateMode,
  });

  @override
  State<PrimaryInputField> createState() => _PrimaryInputFieldState();
}

class _PrimaryInputFieldState extends State<PrimaryInputField> {
  final GlobalKey _inputFieldKey = GlobalKey();
  double _inputHeight = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateInputHeight();
    });
  }

  void _updateInputHeight() {
    final RenderBox? renderBox =
        _inputFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && mounted) {
      final newHeight = renderBox.size.height;
      if (_inputHeight != newHeight) {
        setState(() {
          _inputHeight = newHeight;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputField = Container(
      key: _inputFieldKey,
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        inputFormatters: widget.inputFormatters,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        readOnly: widget.readOnly,
        textAlign: widget.textAlign,
        autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.disabled,
        style: TextStyle(fontSize: 16.sp, color: Colors.black87),
        decoration: _getInputDecoration(context),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        if (widget.trailingButton != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: inputField),
              SizedBox(width: 12.w),
              // 关键：使用 _inputHeight 强制设置按钮容器高度，并居中按钮内容
              SizedBox(
                height: _inputHeight > 0 ? _inputHeight : null, // 未测量时暂不限制
                child: Center(
                  child: widget.trailingButton!,
                ),
              ),
            ],
          )
        else
          inputField,
      ],
    );
  }

  InputDecoration _getInputDecoration(BuildContext context) {
    return InputDecoration(
      hintText: widget.hintText,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.sp),
      filled: true,
      fillColor: widget.enabled ? Colors.grey[50] : Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: widget.prefixIcon != null ? 16.w : 20.w,
        vertical: 16.h,
      ),
      prefixIcon: widget.prefixIcon != null
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: IconTheme(
                data: IconThemeData(
                  color: Theme.of(context).primaryColor,
                  size: 20.sp,
                ),
                child: widget.prefixIcon!,
              ),
            )
          : null,
      suffixIcon: widget.suffixIcon,
      counterText: widget.maxLength != null ? '' : null,
    );
  }
}
