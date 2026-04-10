import 'package:flutter/material.dart';
import '../services/token_service.dart';
import '../../data/models/user_model.dart';

/// 认证服务
/// 管理用户登录状态、用户信息等
class AuthService extends ChangeNotifier {
  final TokenService _tokenService = TokenService.instance;

  /// 单例模式
  static AuthService? _instance;
  static AuthService get instance {
    _instance ??= AuthService._internal();
    return _instance!;
  }

  AuthService._internal();
  // 用户信息
  UserModel? _user;

  // 登录状态
  bool _isLoggedIn = false;

  // 是否正在登录
  bool _isLoggingIn = false;

  /// 获取用户信息
  UserModel? get user => _user;

  /// 是否已登录
  bool get isLoggedIn => _isLoggedIn;

  /// 是否正在登录
  bool get isLoggingIn => _isLoggingIn;

  /// 初始化认证服务
  Future<void> initialize() async {
    _isLoggedIn = await _tokenService.isLoggedIn();
    if (_isLoggedIn) {
      // TODO: 从本地存储加载用户信息
    }
    notifyListeners();
  }

  /// 登录成功
  Future<bool> login({
    required String token,
    String? expireSeconds,
    String? refreshToken,
    String? refreshExpireSeconds,
    UserModel? user,
  }) async {
    try {
      _isLoggingIn = true;
      notifyListeners();

      // 保存Token
      final saved = await _tokenService.saveToken(
        token: token,
        expireSeconds: expireSeconds,
        refreshToken: refreshToken,
        refreshExpireSeconds: refreshExpireSeconds,
      );

      if (saved) {
        _isLoggedIn = true;
        _user = user;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      return false;
    } finally {
      _isLoggingIn = false;
      notifyListeners();
    }
  }

  /// 退出登录
  Future<bool> logout() async {
    try {
      // 清除Token
      await _tokenService.clearToken();

      // 清除用户信息
      _user = null;
      _isLoggedIn = false;
      notifyListeners();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// 检查Token是否过期
  Future<bool> isTokenExpired() async {
    return await _tokenService.isTokenExpired();
  }

  /// 刷新Token
  Future<bool> refreshToken(String newToken, {String? expireSeconds}) async {
    try {
      final saved = await _tokenService.saveToken(
        token: newToken,
        expireSeconds: expireSeconds,
      );

      return saved;
    } catch (e) {
      return false;
    }
  }

  /// 更新用户信息
  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }
}
