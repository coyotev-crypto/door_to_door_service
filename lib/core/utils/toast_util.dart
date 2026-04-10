import 'package:flutter/material.dart';

class ToastUtil {
  // 显示普通消息
  static void showMessage(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    double fontSize = 14.0,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _ToastMessage(
        message: message,
        duration: duration,
        backgroundColor: backgroundColor,
        textColor: textColor,
        fontSize: fontSize,
      ),
    );

    overlay.insert(overlayEntry);

    // 自动移除
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  // 显示错误消息
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showMessage(
      context,
      message,
      duration: duration,
      backgroundColor: Colors.red[50]!,
      textColor: Colors.red[700]!,
      fontSize: 14.0,
    );
  }

  // 显示成功消息
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showMessage(
      context,
      message,
      duration: duration,
      backgroundColor: Colors.green[50]!,
      textColor: Colors.green[700]!,
      fontSize: 14.0,
    );
  }

  // 显示警告消息
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showMessage(
      context,
      message,
      duration: duration,
      backgroundColor: Colors.orange[50]!,
      textColor: Colors.orange[700]!,
      fontSize: 14.0,
    );
  }
}

class _ToastMessage extends StatelessWidget {
  final String message;
  final Duration duration;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;

  const _ToastMessage({
    Key? key,
    required this.message,
    required this.duration,
    required this.backgroundColor,
    required this.textColor,
    required this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).viewInsets.bottom + 50,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 根据背景色显示不同的图标
              if (backgroundColor == Colors.red[50] ||
                  backgroundColor == Colors.red[50]!.withOpacity(0.9))
                Icon(Icons.error_outline, color: textColor, size: 20),
              if (backgroundColor == Colors.green[50] ||
                  backgroundColor == Colors.green[50]!.withOpacity(0.9))
                Icon(Icons.check_circle_outline, color: textColor, size: 20),
              if (backgroundColor == Colors.orange[50] ||
                  backgroundColor == Colors.orange[50]!.withOpacity(0.9))
                Icon(Icons.warning_amber_outlined, color: textColor, size: 20),
              if (backgroundColor == Colors.black87)
                Icon(Icons.info_outline, color: textColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
