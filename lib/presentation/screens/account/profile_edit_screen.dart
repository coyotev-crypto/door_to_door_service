import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../core/themes/app_theme.dart';
import '../../controllers/profile_controller.dart';

/// 编辑个人信息 — 温润质感
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _ctrl = Get.find<ProfileController>();
  final _formKey = GlobalKey<FormState>();
  late final _nickCtrl = TextEditingController(text: _ctrl.nickname);
  late final _phoneCtrl = TextEditingController(text: _ctrl.user?.phoneNumber ?? '');
  late final _emailCtrl = TextEditingController(text: _ctrl.email);
  late final _remarkCtrl = TextEditingController(text: _ctrl.remark);
  String _gender = '0';

  @override
  void initState() { super.initState(); _gender = _ctrl.gender; }

  @override
  void dispose() { _nickCtrl.dispose(); _phoneCtrl.dispose(); _emailCtrl.dispose(); _remarkCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        title: Text('编辑个人信息', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        centerTitle: true, backgroundColor: Colors.white, elevation: 0, scrolledUnderElevation: 0.5,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, size: 20.sp, color: AppTheme.textPrimary), onPressed: () => Get.back()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
        child: Form(key: _formKey, child: Column(children: [
          _avatarSection(),
          SizedBox(height: 28.h),
          _field(ctrl: _nickCtrl, label: '昵称', hint: '请输入昵称', onChanged: (v) => _ctrl.updateNickname(v), validator: (v) => v == null || v.trim().isEmpty ? '请输入昵称' : v.trim().length < 2 ? '昵称至少需要2个字符' : null),
          SizedBox(height: 14.h),
          _field(ctrl: _phoneCtrl, label: '手机号', hint: '请输入手机号', enabled: false, validator: (v) => v == null || v.trim().isEmpty ? '请输入手机号' : !RegExp(r'^1[3-9]\d{9}$').hasMatch(v) ? '请输入正确的手机号' : null),
          SizedBox(height: 14.h),
          _field(ctrl: _emailCtrl, label: '邮箱', hint: '请输入邮箱', onChanged: (v) => _ctrl.updateEmail(v), validator: (v) => v == null || v.trim().isEmpty ? null : !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v) ? '请输入正确的邮箱地址' : null),
          SizedBox(height: 14.h),
          _genderSelector(),
          SizedBox(height: 14.h),
          _field(ctrl: _remarkCtrl, label: '个人介绍', hint: '请输入个人介绍', maxLines: 3, onChanged: (v) => _ctrl.updateRemark(v)),
          SizedBox(height: 32.h),
          Obx(() => _gradientBtn(loading: _ctrl.isSavingUserInfo, label: '保存', onTap: _ctrl.saveUserInfo)),
        ])),
      ),
    );
  }

  Widget _avatarSection() {
    return Obx(() {
      final user = _ctrl.user;
      final uploading = _ctrl.isUploadingAvatar;
      return Center(child: Stack(children: [
        GestureDetector(
          onTap: uploading ? null : () => _ctrl.selectAvatar(),
          child: Container(
            width: 96.w, height: 96.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.creamBg,
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2), width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: user?.avatar != null
                ? Image.network(user!.avatar!, fit: BoxFit.cover, cacheWidth: 256, errorBuilder: (_, __, ___) => _avatarPlaceholder())
                : uploading ? _avatarPlaceholder() : _avatarPlaceholder(),
          ),
        ),
        Positioned(
          bottom: 0, right: 0,
          child: Container(
            width: 32.w, height: 32.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.gold, AppTheme.amber]),
              shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2),
            ),
            child: uploading
                ? SizedBox(width: 16.w, height: 16.w, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(Icons.camera_alt_rounded, size: 16.sp, color: Colors.white),
          ),
        ),
      ]));
    });
  }

  Widget _avatarPlaceholder() => Container(color: AppTheme.creamBg, child: Icon(Icons.person_rounded, size: 44.sp, color: AppTheme.textMuted));

  Widget _genderSelector() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('性别', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      SizedBox(height: 8.h),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(color: AppTheme.creamBg, borderRadius: BorderRadius.circular(12.r)),
        child: Row(children: [
          _genderOption('0', '未知'), SizedBox(width: 16.w),
          _genderOption('1', '男'), SizedBox(width: 16.w),
          _genderOption('2', '女'),
        ]),
      ),
    ]);
  }

  Widget _genderOption(String v, String label) {
    return GestureDetector(
      onTap: () { setState(() { _gender = v; _ctrl.updateGender(v); }); },
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 20.w, height: 20.w,
          margin: EdgeInsets.only(right: 6.w),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _gender == v ? AppTheme.gold : AppTheme.textMuted, width: 2)),
          child: _gender == v ? Center(child: Container(width: 10.w, height: 10.w, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.gold))) : null,
        ),
        Text(label, style: TextStyle(fontSize: 14.sp, color: AppTheme.textPrimary)),
      ]),
    );
  }

  Widget _field({required TextEditingController ctrl, required String label, required String hint, int maxLines = 1, bool enabled = true, void Function(String)? onChanged, String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      SizedBox(height: 8.h),
      TextFormField(
        controller: ctrl, maxLines: maxLines, enabled: enabled, onChanged: onChanged, validator: validator,
        style: TextStyle(fontSize: 15.sp, color: enabled ? AppTheme.textPrimary : AppTheme.textMuted),
        decoration: InputDecoration(
          hintText: hint, hintStyle: TextStyle(fontSize: 14.sp, color: AppTheme.textMuted),
          filled: true, fillColor: enabled ? AppTheme.creamBg : AppTheme.creamBg.withValues(alpha: 0.9),
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppTheme.gold)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppTheme.danger)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppTheme.danger)),
        ),
      ),
    ]);
  }

  Widget _gradientBtn({required bool loading, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTheme.gold, AppTheme.amber]),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [BoxShadow(color: AppTheme.gold.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Center(child: loading
            ? SizedBox(width: 22.w, height: 22.w, child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Text(label, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.5))),
      ),
    );
  }
}
