import 'dart:io';
import 'package:door_to_door_service/core/services/image_upload_service.dart';
import 'package:door_to_door_service/core/utils/toast_util.dart';
import 'package:door_to_door_service/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/log_util.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

/// 个人中心控制器
class ProfileController extends GetxController {
  final String _tag = 'ProfileController';
  final AuthService _authService = AuthService.instance;
  final UserRepository _userRepository = UserRepository();
  final ImagePicker _imagePicker = ImagePicker();
  final ImageUploadService _imageUploadService = ImageUploadService();

  // 用户信息
  final Rx<UserModel?> _user = Rx<UserModel?>(null);

  // 是否正在上传头像
  final RxBool _isUploadingAvatar = false.obs;

  // 是否正在上传头像
  bool get isUploadingAvatar => _isUploadingAvatar.value;

  // 是否已登录
  final RxBool _isLoggedIn = false.obs;

  // 是否正在加载
  final RxBool _isLoading = false.obs;

  // 订单统计
  final RxInt _pendingPaymentCount = 0.obs;
  final RxInt _pendingServiceCount = 0.obs;
  final RxInt _inProgressCount = 0.obs;
  final RxInt _completedCount = 0.obs;

  /// 用户信息
  UserModel? get user => _user.value;

  /// 是否已登录
  bool get isLoggedIn => _isLoggedIn.value;

  /// 是否正在加载
  bool get isLoading => _isLoading.value;

  /// 是否正在保存用户信息
  final RxBool _isSavingUserInfo = false.obs;

  /// 是否正在保存用户信息
  bool get isSavingUserInfo => _isSavingUserInfo.value;

  /// 昵称
  final RxString _nickname = ''.obs;

  /// 昵称
  String get nickname => _nickname.value;

  /// 邮箱
  final RxString _email = ''.obs;

  /// 邮箱
  String get email => _email.value;

  /// 性别
  final RxString _gender = '0'.obs; // 默认为未知

  /// 性别
  String get gender => _gender.value;

  /// 备注
  final RxString _remark = ''.obs;

  /// 备注
  String get remark => _remark.value;

  /// 待支付订单数量
  int get pendingPaymentCount => _pendingPaymentCount.value;

  /// 待服务订单数量
  int get pendingServiceCount => _pendingServiceCount.value;

  /// 进行中订单数量
  int get inProgressCount => _inProgressCount.value;

  /// 已完成订单数量
  int get completedCount => _completedCount.value;

  @override
  void onInit() {
    super.onInit();
    _initUserData();
    _loadOrderStatistics();
  }

  @override
  void onReady() {
    super.onReady();
    if (_isLoggedIn.value) {
      // 在控制器生命周期中仅触发一次首次刷新，避免在 Widget build 中重复请求
      refreshUserInfo();
    }
    // 监听认证服务状态变化
    ever(_authService.isLoggedInRx, (_) {
      _onAuthStateChanged();
    });
    ever(_authService.userRx, (user) {
      _onAuthStateChanged();
    });
  }

  /// 初始化用户数据
  void _initUserData() {
    _user.value = _authService.user;
    _isLoggedIn.value = _authService.isLoggedIn;
  }

  /// 认证状态变化回调
  void _onAuthStateChanged() {
    _initUserData();
    if (_isLoggedIn.value) {
      _loadOrderStatistics();
    } else {
      _resetOrderStatistics();
    }
  }

  /// 重置订单统计
  void _resetOrderStatistics() {
    _pendingPaymentCount.value = 0;
    _pendingServiceCount.value = 0;
    _inProgressCount.value = 0;
    _completedCount.value = 0;
  }

  /// 加载订单统计
  Future<void> _loadOrderStatistics() async {
    try {
      // TODO: 调用API获取订单统计
      // 暂时使用模拟数据
      _pendingPaymentCount.value = 2;
      _pendingServiceCount.value = 3;
      _inProgressCount.value = 1;
      _completedCount.value = 10;
    } catch (e) {
      ToastUtil.showError('加载订单统计失败: $e');
    }
  }

  /// 刷新用户信息
  Future<void> refreshUserInfo() async {
    if (!_isLoggedIn.value) return;

    _isLoading.value = true;
    try {
      // 1. 先从本地获取用户信息
      _user.value = _authService.user;
      LogUtil.d('从本地加载用户信息: ${_user.value?.phoneNumber}', tag: _tag);

      // 2. 从网络获取最新用户信息
      final userInfo = await _userRepository.getUserInfo();

      // 3. 更新本地用户信息
      await _authService.updateUser(userInfo);

      // 4. 更新控制器中的用户信息
      _user.value = userInfo;

      LogUtil.d('从网络加载用户信息成功: ${userInfo.phoneNumber}', tag: _tag);
    } catch (e) {
      LogUtil.e('刷新用户信息失败: $e', tag: _tag);
      ToastUtil.showError('刷新用户信息失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// 跳转到登录页
  void navigateToLogin() {
    Get.toNamed('/login');
  }

  /// 跳转到个人信息编辑页
  void navigateToProfileEdit() {
    // 初始化编辑用户信息
    _initEditUserInfo();
    Get.toNamed('/profile-edit');
  }

  /// 初始化编辑用户信息
  void _initEditUserInfo() {
    if (_user.value != null) {
      _nickname.value = _user.value!.nickname ?? '';
      _email.value = _user.value!.email ?? '';
      _gender.value = _user.value!.gender ?? '0';
      _remark.value = _user.value!.remark ?? '';
    }
  }

  /// 更新昵称
  void updateNickname(String value) {
    _nickname.value = value;
  }

  /// 更新邮箱
  void updateEmail(String value) {
    _email.value = value;
  }

  /// 更新性别
  void updateGender(String value) {
    _gender.value = value;
  }

  /// 更新备注
  void updateRemark(String value) {
    _remark.value = value;
  }

  /// 保存用户信息
  Future<void> saveUserInfo() async {
    // 验证昵称
    if (_nickname.value.trim().isEmpty) {
      ToastUtil.showError('请输入昵称');
      return;
    }

    if (_nickname.value.trim().length < 2) {
      ToastUtil.showError('昵称至少需要2个字符');
      return;
    }

    // 验证邮箱（如果已填写）
    if (_email.value.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@[\w-]+\.[\w-]{2,4}$');
      if (!emailRegex.hasMatch(_email.value)) {
        ToastUtil.showError('请输入正确的邮箱地址');
        return;
      }
    }

    _isSavingUserInfo.value = true;
    try {
      // 调用API更新用户信息
      final updatedUser = await _userRepository.updateUserInfo(
        nickname: _nickname.value,
        email: _email.value,
        gender: _gender.value,
        remark: _remark.value,
      );

      // 更新本地用户信息
      await _authService.updateUser(updatedUser);

      // 更新控制器中的用户信息
      _user.value = updatedUser;

      ToastUtil.showSuccess('用户信息更新成功');

      // 返回上一页
      Get.back();
    } catch (e) {
      ToastUtil.showError('更新用户信息失败: $e');
    } finally {
      _isSavingUserInfo.value = false;
    }
  }

  /// 跳转到入驻页面
  void navigateToProviderJoin() {
    Get.toNamed(RouteNames.providerJoin);
  }

  /// 跳转到资质材料页面
  void navigateToProviderQualification() {
    Get.toNamed(RouteNames.providerQualification);
  }

  /// 跳转到服务管理列表页面
  void navigateToProviderService() {
    Get.toNamed(RouteNames.providerServiceList);
  }

  /// 跳转到账户安全页
  void navigateToAccountSecurity() {
    Get.toNamed(RouteNames.accountSecurity);
  }

  /// 跳转到订单列表页
  void navigateToOrderList(int initialTabIndex) {
    // TODO: 实现订单列表页面
    ToastUtil.showError('订单列表功能开发中');
  }

  /// 跳转到地址管理页
  void navigateToAddressManage() {
    Get.toNamed(RouteNames.addressManage);
  }

  /// 跳转到收藏列表页
  void navigateToFavorites() {
    Get.toNamed(RouteNames.favorites);
  }

  /// 跳转到优惠券页
  void navigateToCoupons() {
    // TODO: 实现优惠券页面
    ToastUtil.showError('优惠券功能开发中');
  }

  /// 跳转到客服中心页
  void navigateToCustomerService() {
    // TODO: 实现客服中心页面
    ToastUtil.showError('客服中心功能开发中');
  }

  /// 跳转到设置页
  void navigateToSettings() {
    Get.toNamed('/settings');
  }

  /// 退出登录
  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // TODO: 调用退出登录API
      await _authService.logout();
      Get.offAllNamed('/login');
    } catch (e) {
      ToastUtil.showError('退出登录失败: $e');
    }
  }

  /// 选择头像
  Future<void> selectAvatar() async {
    try {
      // 显示选择来源对话框
      final source = await Get.dialog<ImageSource>(
        AlertDialog(
          title: const Text('选择头像'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      // 选择图片
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile == null) return;

      // 上传头像
      await uploadAvatar(File(pickedFile.path));
    } catch (e) {
      LogUtil.e('选择头像失败: $e', tag: _tag);
      ToastUtil.showError('选择头像失败: $e');
    }
  }

  /// 上传头像
  Future<void> uploadAvatar(File imageFile) async {
    if (_isUploadingAvatar.value) return;

    _isUploadingAvatar.value = true;
    try {
      // 上传图片
      final imageUrl = await _imageUploadService.uploadImage(imageFile);

      // 更新用户头像
      await updateAvatar(imageUrl);

      ToastUtil.showSuccess('头像更新成功');
    } catch (e) {
      LogUtil.e('上传头像失败: $e', tag: _tag);
      ToastUtil.showError('上传头像失败: $e');
    } finally {
      _isUploadingAvatar.value = false;
    }
  }

  /// 更新头像
  Future<void> updateAvatar(String avatarUrl) async {
    try {
      // 调用API更新用户头像
      final updatedUser = await _userRepository.updateUserInfo(
        avatar: avatarUrl,
      );

      // 更新本地用户信息
      await _authService.updateUser(updatedUser);

      // 更新控制器中的用户信息
      _user.value = updatedUser;
    } catch (e) {
      LogUtil.e('更新头像失败: $e', tag: _tag);
      rethrow;
    }
  }
}
