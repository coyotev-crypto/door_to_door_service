import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/profile_header_widget.dart';
import '../../widgets/profile_function_item_widget.dart';

/// 个人中心页面组件
class ProfileWidget extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();

  ProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // 已登录状态
        return _buildLoggedInView(context, controller);
      }),
    );
  }

  /// 构建已登录视图
  Widget _buildLoggedInView(
      BuildContext context, ProfileController controller) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.refreshUserInfo();
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 用户信息头部
          ProfileHeaderWidget(controller: controller),
          // 订单管理
          _buildOrderManagement(context, controller),
          SizedBox(height: 16.h),
          // 常用功能
          _buildCommonFunctions(context, controller),
          SizedBox(height: 16.h),
          // 入驻功能
          _buildProviderFunctions(context, controller),
          SizedBox(height: 16.h),
          // 其他功能
          // _buildOtherFunctions(context, controller),
          // SizedBox(height: 16.h),
          // 退出登录按钮
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: ElevatedButton(
              onPressed: () => controller.logout(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(color: Colors.red.withOpacity(0.2)),
                ),
                elevation: 0,
              ),
              child: Text(
                '退出登录',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  /// 构建订单管理
  Widget _buildOrderManagement(
      BuildContext context, ProfileController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
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
      child: Column(
        children: [
          // 订单标题和全部订单
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '我的订单',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () => controller.navigateToOrderList(0),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Text(
                      '全部订单',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20.sp,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // 订单状态
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrderStatusItem(
                icon: Icons.payment_rounded,
                label: '待支付',
                count: controller.pendingPaymentCount,
                onTap: () => controller.navigateToOrderList(0),
              ),
              _buildOrderStatusItem(
                icon: Icons.access_time_rounded,
                label: '待服务',
                count: controller.pendingServiceCount,
                onTap: () => controller.navigateToOrderList(1),
              ),
              _buildOrderStatusItem(
                icon: Icons.local_shipping_rounded,
                label: '进行中',
                count: controller.inProgressCount,
                onTap: () => controller.navigateToOrderList(2),
              ),
              _buildOrderStatusItem(
                icon: Icons.check_circle_rounded,
                label: '已完成',
                count: controller.completedCount,
                onTap: () => controller.navigateToOrderList(3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建订单状态项
  Widget _buildOrderStatusItem({
    required IconData icon,
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Stack(
            children: [
              Icon(
                icon,
                size: 28.sp,
                color: Colors.black87,
              ),
              if (count > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16.w,
                      minHeight: 16.h,
                    ),
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建常用功能
  Widget _buildCommonFunctions(
      BuildContext context, ProfileController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
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
      child: Column(
        children: [
          _buildFunctionItem(
            icon: Icons.location_on_rounded,
            label: '地址管理',
            onTap: () => controller.navigateToAddressManage(),
          ),
          _buildFunctionItem(
            icon: Icons.favorite_rounded,
            label: '我的收藏',
            onTap: () => controller.navigateToFavorites(),
          ),
          // _buildFunctionItem(
          //   icon: Icons.confirmation_number_rounded,
          //   label: '优惠券',
          //   onTap: () => controller.navigateToCoupons(),
          // ),
          // _buildFunctionItem(
          //   icon: Icons.support_agent_rounded,
          //   label: '客服中心',
          //   onTap: () => controller.navigateToCustomerService(),
          // ),
        ],
      ),
    );
  }

  /// 构建入驻功能
  Widget _buildProviderFunctions(
      BuildContext context, ProfileController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
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
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(
                  Icons.business_center_rounded,
                  size: 20.sp,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 8.w),
                Text(
                  '服务商入驻',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          _buildFunctionItem(
            icon: Icons.description_rounded,
            label: '资质材料',
            onTap: () => controller.navigateToProviderQualification(),
          ),
          _buildFunctionItem(
            icon: Icons.room_service_rounded,
            label: '完善服务',
            onTap: () => controller.navigateToProviderService(),
          ),
        ],
      ),
    );
  }

  /// 构建其他功能
  Widget _buildOtherFunctions(
      BuildContext context, ProfileController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
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
      child: Column(
        children: [
          _buildFunctionItem(
            icon: Icons.settings_rounded,
            label: '设置',
            onTap: () => controller.navigateToSettings(),
          ),
          _buildFunctionItem(
            icon: Icons.info_rounded,
            label: '关于我们',
            onTap: () {
              // TODO: 实现关于我们页面
              Get.snackbar('提示', '关于我们功能开发中');
            },
          ),
        ],
      ),
    );
  }

  /// 构建功能项
  Widget _buildFunctionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ProfileFunctionItemWidget(
      icon: icon,
      label: label,
      onTap: onTap,
    );
  }
}
