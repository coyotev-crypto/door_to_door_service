import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../core/themes/app_theme.dart';
import '../../../data/repositories/auth_repository.dart';

/// 个人中心 — 温润质感
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = AuthService.instance;
  final _repo = AuthRepository();
  bool _loading = false;

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 52.w, height: 52.w, decoration: BoxDecoration(color: AppTheme.gold.withOpacity(0.08), shape: BoxShape.circle), child: Icon(Icons.logout_rounded, size: 26.sp, color: AppTheme.gold)),
            SizedBox(height: 16.h),
            Text('退出登录', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            SizedBox(height: 6.h),
            Text('确定要退出登录吗？', style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary)),
            SizedBox(height: 24.h),
            Row(children: [
              Expanded(child: GestureDetector(onTap: () => Get.back(result: false), child: Container(height: 44.h, decoration: BoxDecoration(color: AppTheme.creamBg, borderRadius: BorderRadius.circular(12.r)), child: Center(child: Text('取消', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)))))),
              SizedBox(width: 12.w),
              Expanded(child: GestureDetector(onTap: () => Get.back(result: true), child: Container(height: 44.h, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.gold, AppTheme.amber]), borderRadius: BorderRadius.circular(12.r)), child: Center(child: Text('确定', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white)))))),
            ]),
          ]),
        ),
      ),
    );
    if (ok != true) return;
    setState(() => _loading = true);
    try {
      await _repo.logout();
      await _auth.logout();
      if (mounted) Get.offAllNamed('/login');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('退出失败: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        centerTitle: true, backgroundColor: Colors.white, elevation: 0,
      ),
      body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Profile Screen', style: TextStyle(fontSize: 15.sp, color: AppTheme.textMuted)),
        SizedBox(height: 20.h),
        GestureDetector(
          onTap: _loading ? null : _logout,
          child: Container(
            height: 48.h, width: 200.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.gold, AppTheme.amber]),
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [BoxShadow(color: AppTheme.gold.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Center(child: _loading
                ? SizedBox(width: 22.w, height: 22.w, child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text('退出登录', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white))),
          ),
        ),
      ])),
    );
  }
}
