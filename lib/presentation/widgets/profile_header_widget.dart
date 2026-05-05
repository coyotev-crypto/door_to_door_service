import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/screen_adapter.dart';
import '../controllers/profile_controller.dart';

/// 个人中心用户信息头部组件
class ProfileHeaderWidget extends StatelessWidget {
  final ProfileController controller;

  const ProfileHeaderWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SizedBox(
        height: 220.h,
        child: Stack(
          children: [
            // 用户信息卡片
            Positioned(
              top: 32.h,
              left: 16.w,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 用户信息
                    Row(
                      children: [
                        // 头像
                        GestureDetector(
                          onTap: () => controller.navigateToProfileEdit(),
                          child: Container(
                            width: 64.w,
                            height: 64.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                              image: controller.user?.avatar != null
                                  ? DecorationImage(
                                      image: NetworkImage(
                                          controller.user!.avatar!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: controller.user?.avatar == null
                                ? Icon(
                                    Icons.person_rounded,
                                    size: 32.sp,
                                    color: Colors.grey[400],
                                  )
                                : null,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // 昵称和手机号
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      controller.user?.nickname ?? '未设置昵称',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  _buildGenderIcon(controller.user?.gender),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                controller.user?.phoneNumber ?? '',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                '个人介绍：${(controller.user?.remark?.trim().isNotEmpty ?? false) ? controller.user!.remark!.trim() : '这个人很神秘，什么都没留下'}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey[500],
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 编辑按钮
                        IconButton(
                          onPressed: () => controller.navigateToProfileEdit(),
                          icon: Icon(
                            Icons.edit_rounded,
                            size: 20.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    // 认证状态
                    Row(
                      children: [
                        _buildAuthStatusItem(
                          icon: Icons.business_center_rounded,
                          label: '服务商入驻',
                          isVerified: false,
                          onTap: () => controller.navigateToProviderJoin(),
                        ),
                        SizedBox(width: 24.w),
                        _buildAuthStatusItem(
                          icon: Icons.security_rounded,
                          label: '账户安全',
                          isVerified: false,
                          onTap: () => controller.navigateToAccountSecurity(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 构建认证状态项
  Widget _buildAuthStatusItem({
    required IconData icon,
    required String label,
    required bool isVerified,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isVerified
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: isVerified ? Colors.green : Colors.orange,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isVerified ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderIcon(String? gender) {
    late final IconData iconData;
    late final Color iconColor;
    late final Color bgColor;

    switch (gender) {
      case '1':
        iconData = Icons.male_rounded;
        iconColor = Colors.blue;
        bgColor = Colors.blue.withOpacity(0.12);
        break;
      case '2':
        iconData = Icons.female_rounded;
        iconColor = Colors.pink;
        bgColor = Colors.pink.withOpacity(0.12);
        break;
      default:
        iconData = Icons.help_outline_rounded;
        iconColor = Colors.grey;
        bgColor = Colors.grey.withOpacity(0.12);
        break;
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 16.sp,
        color: iconColor,
      ),
    );
  }
}
