import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/token_service.dart';
import '../utils/log_util.dart';
import '../../data/models/user_model.dart';
import 'agora_chat_service.dart';

/// 认证服务
/// 管理用户登录状态、用户信息等
class AuthService extends GetxService {
  final TokenService _tokenService = TokenService.instance;

  // 本地存储键名
  static const String _userKey = 'user_info';

  /// 单例模式
  static AuthService? _instance;
  static AuthService get instance {
    _instance ??= AuthService._internal();
    return _instance!;
  }

  AuthService._internal();
  // 用户信息
  final Rx<UserModel?> _user = Rx<UserModel?>(null);

  // 登录状态
  final RxBool _isLoggedIn = false.obs;

  // 是否正在登录
  final RxBool _isLoggingIn = false.obs;

  /// 获取用户信息响应式变量
  Rx<UserModel?> get userRx {
    return _user;
  }

  /// 获取登录状态响应式变量
  RxBool get isLoggedInRx {
    return _isLoggedIn;
  }

  /// 获取用户信息
  UserModel? get user => _user.value;

  /// 是否已登录
  bool get isLoggedIn => _isLoggedIn.value;

  /// 是否正在登录
  bool get isLoggingIn => _isLoggingIn.value;

  /// 初始化认证服务
  Future<void> initialize() async {
    _isLoggedIn.value = await _tokenService.isLoggedIn();
    if (_isLoggedIn.value) {
      await _loadUserInfoFromLocal();
    }
  }

  /// 从本地存储加载用户信息
  Future<void> _loadUserInfoFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('$_userKey.phoneNumber');

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        final Map<String, dynamic> userData = {
          'id': prefs.getString('$_userKey.id') ?? '',
          'phoneNumber': phoneNumber,
          'nickname': prefs.getString('$_userKey.nickname'),
          'avatar': prefs.getString('$_userKey.avatar'),
          'email': prefs.getString('$_userKey.email'),
          'gender': prefs.getString('$_userKey.gender'),
          'remark': prefs.getString('$_userKey.remark'),
          'roleId': int.tryParse(prefs.getString('$_userKey.roleId') ?? ''),
          'hasPaymentPassword': prefs.getString('$_userKey.hasPaymentPassword'),
          'createdAt': prefs.getString('$_userKey.createdAt'),
          'updatedAt': prefs.getString('$_userKey.updatedAt'),
        };

        _user.value = UserModel.fromJson(userData);
        LogUtil.d('用户信息加载成功: ${_user.value?.phoneNumber}');
      }
    } catch (e) {
      LogUtil.e('加载用户信息失败: $e');
    }
  }

  /// 保存用户信息到本地存储
  Future<void> _saveUserInfoToLocal(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('$_userKey.id', user.id);
      await prefs.setString('$_userKey.phoneNumber', user.phoneNumber);
      if (user.nickname != null) {
        await prefs.setString('$_userKey.nickname', user.nickname!);
      }
      if (user.avatar != null) {
        await prefs.setString('$_userKey.avatar', user.avatar!);
      }
      if (user.email != null) {
        await prefs.setString('$_userKey.email', user.email!);
      }
      if (user.gender != null) {
        await prefs.setString('$_userKey.gender', user.gender!);
      }
      if (user.remark != null) {
        await prefs.setString('$_userKey.remark', user.remark!);
      }
      if (user.roleId != null) {
        await prefs.setString('$_userKey.roleId', user.roleId.toString());
      }
      if (user.hasPaymentPassword != null) {
        await prefs.setString(
            '$_userKey.hasPaymentPassword', user.hasPaymentPassword.toString());
      }
      if (user.createdAt != null) {
        await prefs.setString(
            '$_userKey.createdAt', user.createdAt!.toIso8601String());
      }
      if (user.updatedAt != null) {
        await prefs.setString(
            '$_userKey.updatedAt', user.updatedAt!.toIso8601String());
      }

      LogUtil.d('用户信息保存成功: ${user.phoneNumber}');
    } catch (e) {
      LogUtil.e('保存用户信息失败: $e');
    }
  }

  /// 清除本地存储的用户信息
  Future<void> _clearUserInfoFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('$_userKey.id');
      await prefs.remove('$_userKey.phoneNumber');
      await prefs.remove('$_userKey.nickname');
      await prefs.remove('$_userKey.avatar');
      await prefs.remove('$_userKey.email');
      await prefs.remove('$_userKey.gender');
      await prefs.remove('$_userKey.remark');
      await prefs.remove('$_userKey.roleId');
      await prefs.remove('$_userKey.hasPaymentPassword');
      await prefs.remove('$_userKey.createdAt');
      await prefs.remove('$_userKey.updatedAt');

      LogUtil.d('用户信息清除成功');
    } catch (e) {
      LogUtil.e('清除用户信息失败: $e');
    }
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
      _isLoggingIn.value = true;

      // 保存Token
      final saved = await _tokenService.saveToken(
        token: token,
        expireSeconds: expireSeconds,
        refreshToken: refreshToken,
        refreshExpireSeconds: refreshExpireSeconds,
      );

      if (saved) {
        _isLoggedIn.value = true;

        // 保存用户信息到本地存储
        if (user != null) {
          _user.value = user;
          await _saveUserInfoToLocal(user);
        }

        return true;
      }

      return false;
    } catch (e) {
      return false;
    } finally {
      _isLoggingIn.value = false;
    }
  }

  /// 退出登录
  Future<bool> logout() async {
    try {
      // 清除Token
      await _tokenService.clearToken();

      // 清除本地存储的用户信息
      await _clearUserInfoFromLocal();

      // 清除用户信息
      _user.value = null;
      _isLoggedIn.value = false;
      final chatService = Get.isRegistered<AgoraChatService>()
          ? AgoraChatService.to
          : Get.put(AgoraChatService(), permanent: true);
      await chatService.logout();
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
  Future<void> updateUser(UserModel user) async {
    _user.value = user;

    // 同步更新到本地存储
    await _saveUserInfoToLocal(user);
  }
}
