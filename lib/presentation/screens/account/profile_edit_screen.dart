import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../controllers/profile_controller.dart';

/// 用户信息编辑页面
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final ProfileController _controller = Get.find<ProfileController>();
  final _formKey = GlobalKey<FormState>();

  // 表单字段控制器
  late TextEditingController _nicknameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _remarkController;

  // 性别选择
  String _selectedGender = '0'; // 默认为未知

  @override
  void initState() {
    super.initState();
    // 初始化表单字段
    _nicknameController = TextEditingController(text: _controller.nickname);
    _phoneController =
        TextEditingController(text: _controller.user?.phoneNumber ?? '');
    _emailController = TextEditingController(text: _controller.email);
    _remarkController = TextEditingController(text: _controller.remark);
    _selectedGender = _controller.gender;
  }

  @override
  void dispose() {
    // 释放资源
    _nicknameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑个人信息'),
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 头像编辑区域
                SizedBox(height: 24.h),
                _buildAvatarSection(),
                SizedBox(height: 24.h),

                // 表单字段
                _buildFormField(
                  controller: _nicknameController,
                  label: '昵称',
                  hintText: '请输入昵称',
                  onChanged: (value) => _controller.updateNickname(value),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入昵称';
                    }
                    if (value.trim().length < 2) {
                      return '昵称至少需要2个字符';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 12.h),

                _buildFormField(
                  controller: _phoneController,
                  label: '手机号',
                  hintText: '请输入手机号',
                  keyboardType: TextInputType.phone,
                  enabled: false, // 手机号不可编辑
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入手机号';
                    }
                    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                      return '请输入正确的手机号';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 12.h),

                _buildFormField(
                  controller: _emailController,
                  label: '邮箱',
                  hintText: '请输入邮箱',
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => _controller.updateEmail(value),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null; // 邮箱为可选字段
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return '请输入正确的邮箱地址';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 12.h),

                // 性别选择
                _buildGenderSelector(),

                SizedBox(height: 12.h),

                _buildFormField(
                  controller: _remarkController,
                  label: '个人介绍',
                  hintText: '请输入个人介绍',
                  maxLines: 3,
                  onChanged: (value) => _controller.updateRemark(value),
                ),

                SizedBox(height: 24.h),

                // 保存按钮
                Obx(() {
                  return _buildSaveButton(_controller.isSavingUserInfo);
                }),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建头像编辑区域
  Widget _buildAvatarSection() {
    return Obx(() {
      return Center(
        child: Stack(
          children: [
            // 头像
            GestureDetector(
              onTap: () {
                // 调用头像选择功能
                if (!_controller.isUploadingAvatar) {
                  _controller.selectAvatar();
                }
              },
              child: Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  image: _controller.user?.avatar != null
                      ? DecorationImage(
                          image: NetworkImage(_controller.user!.avatar!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _controller.user?.avatar == null
                    ? Icon(
                        Icons.person_rounded,
                        size: 50.sp,
                        color: Colors.grey[400],
                      )
                    : _controller.isUploadingAvatar
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 30.w,
                                height: 30.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                            ),
                          )
                        : null,
              ),
            ),
            // 编辑图标
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: AppTheme.servicePrimaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: _controller.isUploadingAvatar
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        Icons.camera_alt_rounded,
                        size: 18.sp,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 构建保存按钮
  Widget _buildSaveButton(bool isSaving) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppTheme.servicePrimaryColor,
            AppTheme.servicePrimaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.servicePrimaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSaving ? null : _controller.saveUserInfo,
          borderRadius: BorderRadius.circular(12.r),
          child: Center(
            child: isSaving
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    '保存',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// 构建性别选择器
  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '性别',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              _buildGenderOption('0', '未知'),
              SizedBox(width: 20.w),
              _buildGenderOption('1', '男'),
              SizedBox(width: 20.w),
              _buildGenderOption('2', '女'),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建性别选项
  Widget _buildGenderOption(String value, String label) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _selectedGender,
          activeColor: AppTheme.servicePrimaryColor,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedGender = value;
                _controller.updateGender(value);
              });
            }
          },
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// 构建表单字段
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 16.sp,
            color: enabled ? Colors.black87 : Colors.grey[600],
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[400],
            ),
            filled: true,
            fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
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
              borderSide: const BorderSide(
                color: AppTheme.servicePrimaryColor,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
