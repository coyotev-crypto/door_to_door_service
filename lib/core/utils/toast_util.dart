import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtil {
  // 显示普通消息
  static void showMessage(
    String message, {
    Toast toastLength = Toast.LENGTH_SHORT,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    double fontSize = 14.0,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  }

  // 显示错误消息
  static void showError(
    String message, {
    Toast toastLength = Toast.LENGTH_SHORT,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: Colors.red[50],
      textColor: Colors.red[700],
      fontSize: 14.0,
    );
  }

  // 显示成功消息
  static void showSuccess(
    String message, {
    Toast toastLength = Toast.LENGTH_SHORT,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: Colors.green[50],
      textColor: Colors.green[700],
      fontSize: 14.0,
    );
  }

  // 显示警告消息
  static void showWarning(
    String message, {
    Toast toastLength = Toast.LENGTH_SHORT,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: Colors.orange[50],
      textColor: Colors.orange[700],
      fontSize: 14.0,
    );
  }
}
