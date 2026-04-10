import 'dart:ui';
import 'package:flutter/material.dart';

/// 屏幕适配工具类
/// 使用375x812作为设计基准尺寸（iPhone X）
class ScreenAdapter {
  // 私有构造函数，防止实例化
  ScreenAdapter._();

  /// 设计稿宽度
  static const double designWidth = 375.0;

  /// 设计稿高度
  static const double designHeight = 812.0;

  /// 屏幕宽度
  static double get screenWidth => window.physicalSize.width / window.devicePixelRatio;

  /// 屏幕高度
  static double get screenHeight => window.physicalSize.height / window.devicePixelRatio;

  /// 屏幕像素密度
  static double get pixelRatio => window.devicePixelRatio;

  /// 状态栏高度
  static double get statusBarHeight => window.padding.top / window.devicePixelRatio;

  /// 底部安全区高度
  static double get bottomBarHeight => window.padding.bottom / window.devicePixelRatio;

  /// 宽度适配系数
  static double get widthScale => screenWidth / designWidth;

  /// 高度适配系数
  static double get heightScale => screenHeight / designHeight;

  /// 根据设计稿宽度进行宽度适配
  /// [value] 设计稿中的尺寸
  static double setWidth(double value) => value * widthScale;

  /// 根据设计稿高度进行高度适配
  /// [value] 设计稿中的尺寸
  static double setHeight(double value) => value * heightScale;

  /// 根据设计稿宽度进行字体适配
  /// [value] 设计稿中的字体大小
  static double setFont(double value) => value * widthScale;

  /// 根据设计稿宽度进行半径适配
  /// [value] 设计稿中的半径值
  static double setRadius(double value) => value * widthScale;

  /// 根据设计稿宽度进行间距适配
  /// [value] 设计稿中的间距值
  static double setSpacing(double value) => value * widthScale;
}

/// 屏幕适配扩展方法
extension ScreenAdapterExtension on num {
  /// 宽度适配
  double get w => ScreenAdapter.setWidth(this.toDouble());

  /// 高度适配
  double get h => ScreenAdapter.setHeight(this.toDouble());

  /// 字体适配
  double get sp => ScreenAdapter.setFont(this.toDouble());

  /// 半径适配
  double get r => ScreenAdapter.setRadius(this.toDouble());

  /// 间距适配
  double get space => ScreenAdapter.setSpacing(this.toDouble());
}

/// 屏幕适配上下文扩展
extension ScreenContextExtension on BuildContext {
  /// 获取屏幕宽度
  double get screenWidth => MediaQuery.of(this).size.width;

  /// 获取屏幕高度
  double get screenHeight => MediaQuery.of(this).size.height;

  /// 获取状态栏高度
  double get statusBarHeight => MediaQuery.of(this).padding.top;

  /// 获取底部安全区高度
  double get bottomBarHeight => MediaQuery.of(this).padding.bottom;

  /// 获取屏幕像素密度
  double get pixelRatio => MediaQuery.of(this).devicePixelRatio;
}
