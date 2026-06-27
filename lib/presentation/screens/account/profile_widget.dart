import 'package:dtd/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/profile_header_widget.dart';
import '../../widgets/profile_function_item_widget.dart';
import '../../widgets/order_stat_widget.dart';

/// 个人中心页面 — 温润质感
class ProfileWidget extends StatelessWidget {
  final ProfileController ctrl = Get.find<ProfileController>();
  ProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isProvider = AuthService.instance.userRx.value?.roleId ==
          AppConfig.MERCHANT_USER_TYPE;
      return RefreshIndicator(
          onRefresh: () async => await ctrl.refreshUserInfo(),
          child: ListView(padding: EdgeInsets.zero, children: [
            SizedBox(height: 14.h),
            ProfileHeaderWidget(controller: ctrl),
            if (!isProvider) ...[
              SizedBox(height: 14.h),
              _orderCard(),
              SizedBox(height: 14.h),
              _menuCard([
                _fnItem(Icons.location_on_rounded, '地址管理',
                    () => ctrl.navigateToAddressManage()),
                _fnItem(Icons.favorite_rounded, '我的收藏',
                    () => ctrl.navigateToFavorites()),
              ]),
            ],
            if (isProvider) ...[
              SizedBox(height: 14.h),
              _menuCard([
                _fnItem(Icons.account_balance_wallet_rounded, '我的钱包',
                    () => ctrl.navigateToWallet()),
                _fnItem(Icons.description_rounded, '资质材料',
                    () => ctrl.navigateToProviderQualification()),
                _fnItem(Icons.room_service_rounded, '完善服务',
                    () => ctrl.navigateToProviderService()),
              ]),
            ],
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: GestureDetector(
                onTap: () => ctrl.logout(),
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                          color: AppTheme.danger.withValues(alpha: 0.2))),
                  child: Center(
                      child: Text('退出登录',
                          style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.danger))),
                ),
              ),
            ),
            SizedBox(height: 32.h),
          ]),
        );
    });
  }

  Widget _orderCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF2D2A26).withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('我的订单',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          GestureDetector(
            onTap: () => ctrl.navigateToOrderList(0),
            behavior: HitTestBehavior.opaque,
            child: Row(children: [
              Text('全部订单',
                  style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted)),
              SizedBox(width: 2.w),
              Icon(Icons.chevron_right_rounded,
                  size: 18.sp, color: AppTheme.textMuted)
            ]),
          ),
        ]),
        SizedBox(height: 18.h),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          OrderStatWidget(
              icon: Icons.payment_rounded,
              label: '待付款',
              count: ctrl.pendingPaymentCount,
              onTap: () => ctrl.navigateToOrderList(1)),
          OrderStatWidget(
              icon: Icons.local_shipping_rounded,
              label: '待发货',
              count: ctrl.pendingServiceCount,
              onTap: () => ctrl.navigateToOrderList(2)),
          OrderStatWidget(
              icon: Icons.play_circle_rounded,
              label: '待收货',
              count: ctrl.inProgressCount,
              onTap: () => ctrl.navigateToOrderList(3)),
          OrderStatWidget(
              icon: Icons.star_border_rounded,
              label: '待评价',
              count: ctrl.completedCount,
              onTap: () => ctrl.navigateToOrderList(4)),
        ]),
      ]),
    );
  }

  Widget _menuCard(List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF2D2A26).withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
      child: Column(children: children),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 6.h),
      child: Row(children: [
        Icon(Icons.business_center_rounded, size: 18.sp, color: AppTheme.gold),
        SizedBox(width: 8.w),
        Text(title,
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
      ]),
    );
  }

  Widget _fnItem(IconData icon, String label, VoidCallback onTap) {
    return ProfileFunctionItemWidget(icon: icon, label: label, onTap: onTap);
  }
}
