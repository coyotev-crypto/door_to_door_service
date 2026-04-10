import 'package:shared_preferences/shared_preferences.dart';
import '../utils/log_util.dart';

/// Token管理服务
/// 负责Token的存储、获取、清除和过期检查
class TokenService {
  static const String _tokenKey = 'auth_token';
  static const String _tokenExpireKey = 'token_expire';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _refreshTokenExpireKey = 'refresh_token_expire';

  /// 单例模式
  static TokenService? _instance;
  static TokenService get instance {
    _instance ??= TokenService._internal();
    return _instance!;
  }

  TokenService._internal();

  /// 保存Token
  Future<bool> saveToken({
    required String token,
    String? expireSeconds,
    String? refreshToken,
    String? refreshExpireSeconds,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 保存Token
      await prefs.setString(_tokenKey, token);

      // 计算并保存Token过期时间
      if (expireSeconds != null) {
        await prefs.setString(_tokenExpireKey, expireSeconds);
      }

      // 保存刷新Token
      if (refreshToken != null) {
        await prefs.setString(_refreshTokenKey, refreshToken);

        // 计算并保存刷新Token过期时间
        if (refreshExpireSeconds != null) {
          await prefs.setString(_refreshTokenExpireKey, refreshExpireSeconds);
        }
      }

      LogUtil.d('Token保存成功');
      return true;
    } catch (e) {
      LogUtil.e('Token保存失败: $e');
      return false;
    }
  }

  /// 获取Token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      // 检查Token是否过期
      if (token != null && await isTokenExpired()) {
        LogUtil.w('Token已过期');
        return null;
      }

      return token;
    } catch (e) {
      LogUtil.e('获取Token失败: $e');
      return null;
    }
  }

  /// 获取刷新Token
  Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);

      // 检查刷新Token是否过期
      if (refreshToken != null && await isRefreshTokenExpired()) {
        LogUtil.w('刷新Token已过期');
        return null;
      }

      return refreshToken;
    } catch (e) {
      LogUtil.e('获取刷新Token失败: $e');
      return null;
    }
  }

  /// 检查Token是否过期
  Future<bool> isTokenExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expireTimeStr = prefs.getString(_tokenExpireKey);

      if (expireTimeStr == null) {
        return false; // 没有设置过期时间，认为未过期
      }

      final expireTime = DateTime.parse(expireTimeStr);
      return DateTime.now().isAfter(expireTime);
    } catch (e) {
      LogUtil.e('检查Token过期失败: $e');
      return false;
    }
  }

  /// 检查刷新Token是否过期
  Future<bool> isRefreshTokenExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expireTimeStr = prefs.getString(_refreshTokenExpireKey);

      if (expireTimeStr == null) {
        return false; // 没有设置过期时间，认为未过期
      }

      final expireTime = DateTime.parse(expireTimeStr);
      return DateTime.now().isAfter(expireTime);
    } catch (e) {
      LogUtil.e('检查刷新Token过期失败: $e');
      return false;
    }
  }

  /// 清除Token
  Future<bool> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_tokenExpireKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_refreshTokenExpireKey);

      LogUtil.d('Token清除成功');
      return true;
    } catch (e) {
      LogUtil.e('Token清除失败: $e');
      return false;
    }
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
