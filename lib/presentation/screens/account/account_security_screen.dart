import 'package:door_to_door_service/presentation/widgets/info_tip_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../controllers/account_security_controller.dart';
import '../../../routes/route_names.dart';

/// 账户安全页面
class AccountSecurityScreen extends GetView<AccountSecurityController> {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '账户安全',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        children: [
          SizedBox(height: 24.h),

          // 安全提示
          const InfoTipWidget(
            icon: Icons.security_rounded,
            message: "保护您的账户安全，建议定期检查并更新安全设置",
          ),
          SizedBox(height: 32.h),
          // 登录密码
          _buildSecurityItem(
            icon: Icons.lock_outline_rounded,
            title: '登录密码',
            subtitle: '定期修改密码，保护账户安全',
            onTap: () => Get.toNamed(RouteNames.changePassword),
          ),

          // 支付密码
          _buildSecurityItem(
            icon: Icons.payment_outlined,
            title: '支付密码',
            subtitle: '用于支付时的安全验证',
            onTap: () {
              Get.toNamed(RouteNames.setPaymentPassword);
            },
          ),

          // 手机号更换
          _buildSecurityItem(
            icon: Icons.phone_android_outlined,
            title: '手机号更换',
            subtitle: '更换绑定的手机号码',
            onTap: () => Get.toNamed(RouteNames.changePhone),
          ),

          // // 登录设备管理
          // _buildSecurityItem(
          //   icon: Icons.devices_outlined,
          //   title: '登录设备管理',
          //   subtitle: '查看和管理已登录的设备',
          //   onTap: () => Get.toNamed(RouteNames.loginDevices),
          // ),

          // SizedBox(height: 32.h),

          // // 账号注销
          // _buildSecurityItem(
          //   icon: Icons.delete_outline_rounded,
          //   title: '账号注销',
          //   subtitle: '永久删除账号及所有数据',
          //   titleColor: Colors.red,
          //   iconColor: Colors.red,
          //   subtitleColor: Colors.red[300],
          //   onTap: () => _showDeleteAccountDialog(context),
          // ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  /// 构建安全设置项
  Widget _buildSecurityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconColor,
    Color? subtitleColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppTheme.servicePrimaryColor)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      icon,
                      size: 24.sp,
                      color: iconColor ?? AppTheme.servicePrimaryColor,
                    )),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: titleColor ?? Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: subtitleColor ?? Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  SizedBox(width: 8.w),
                  trailing,
                ],
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20.sp,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 显示注销账号确认对话框
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            const Text('注销账号'),
          ],
        ),
        content: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Text(
            '注销账号后，您的所有数据将被永久删除，无法恢复。确定要注销吗？',
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              textStyle: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(RouteNames.deleteAccount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
