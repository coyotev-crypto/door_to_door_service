import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ToastUtil {
  // 显示普通消息
  static void showMessage(
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackPosition snackPosition = SnackPosition.TOP,
    Color textColor = Colors.white,
    double fontSize = 14.0,
  }) {
    Get.snackbar(
      '提示',
      message,
      duration: duration,
      snackPosition: snackPosition,
    );
  }

  // 显示错误消息
  static void showError(
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackPosition snackPosition = SnackPosition.TOP,
  }) {
    Get.snackbar(
      '错误',
      message,
      duration: duration,
      snackPosition: snackPosition,
      colorText: Colors.red[700],
    );
  }

  // 显示成功消息
  static void showSuccess(
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackPosition snackPosition = SnackPosition.TOP,
  }) {
    Get.snackbar(
      '成功',
      message,
      duration: duration,
      snackPosition: snackPosition,
      colorText: Colors.green[700],
    );
  }

  // 显示警告消息
  static void showWarning(
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackPosition snackPosition = SnackPosition.TOP,
  }) {
    Get.snackbar(
      '警告',
      message,
      duration: duration,
      snackPosition: snackPosition,
      colorText: Colors.orange[700],
    );
  }
}
