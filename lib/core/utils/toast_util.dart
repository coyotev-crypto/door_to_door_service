import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ToastUtil {
  /// 获取 ScaffoldMessengerState
  static ScaffoldMessengerState? get _messenger {
    try {
      final ctx = Get.context;
      if (ctx == null) return null;
      return ScaffoldMessenger.of(ctx);
    } catch (_) {
      return null;
    }
  }

  /// iOS 风格 Toast
  static void _show({
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    final ms = _messenger;
    if (ms == null) return;
    ms.hideCurrentSnackBar();
    ms.showSnackBar(SnackBar(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(message,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
                textAlign: TextAlign.center),
          ),
        ],
      ),
      backgroundColor: const Color(0xDD3A3A3A),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      duration: duration,
      margin: const EdgeInsets.fromLTRB(40, 0, 40, 54),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ));
  }

  // 显示普通消息
  static void showMessage(String message, {Duration duration = const Duration(seconds: 2)}) {
    _show(message: message, duration: duration);
  }

  // 显示错误消息
  static void showError(String message, {Duration duration = const Duration(seconds: 2)}) {
    _show(message: message, icon: Icons.cancel_rounded, duration: duration);
  }

  // 显示成功消息
  static void showSuccess(String message, {Duration duration = const Duration(seconds: 2)}) {
    _show(message: message, icon: Icons.check_circle_rounded, duration: duration);
  }

  // 显示警告消息
  static void showWarning(String message, {Duration duration = const Duration(seconds: 2)}) {
    _show(message: message, icon: Icons.error_rounded, duration: duration);
  }
}
