import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_theme.dart';
import '../../../routes/route_names.dart';
import '../../controllers/wallet_controller.dart';
import '../../widgets/common_app_bar.dart';

/// 收款账号管理页面 - 主流应用设计参考
/// 支持支付宝、微信等多个账号绑定和管理
class PaymentAccountScreen extends GetView<WalletController> {
  const PaymentAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: const CommonAppBar(title: '收款账号'),
      body: Obx(
        () => ListView(
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 40.h),
          children: [
            // 提示信息卡片
            _buildInfoBanner(),
            if (controller.paymentAccounts.isNotEmpty) ...[
              SizedBox(height: 24.h),
              // 已绑定账号分组
              _buildBoundAccountsSection(),
            ],
            SizedBox(height: 24.h),
            // 可绑定方式分组
            _buildBindableMethodsSection(),
            SizedBox(height: 24.h),
            // 绑定规则提示
            _buildBindingRulesTip(),
          ],
        ),
      ),
    );
  }

  /// 信息提示卡片 - 温润设计风格
  Widget _buildInfoBanner() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.warmBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: AppTheme.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: AppTheme.amber,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '绑定收款账号',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '绑定后可直接提现到账号，加快收款速度',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 已绑定的账号分组
  Widget _buildBoundAccountsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分组标题
        Text(
          '已绑定账号',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        // 已绑定账号卡片列表
        ...controller.paymentAccounts.map((account) {
          final isAlipay = account.method == 'alipay';
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildAccountCard(
              method: isAlipay ? '支付宝' : (account.method == 'wechat' ? '微信' : '银行卡'),
              icon: isAlipay ? '🅰️' : (account.method == 'wechat' ? '💚' : '🏦'),
              account: account.accountNoMask,
              realName: account.accountName,
              isBound: true,
              isPrimary: account.isPrimary,
              onManage: () {
                // TODO: 实现管理逻辑，比如设为默认、删除等
              },
            ),
          );
        }),
      ],
    );
  }

  /// 账号卡片 - 主流应用设计
  Widget _buildAccountCard({
    required String method,
    required String icon,
    required String account,
    required String realName,
    required bool isBound,
    required bool isPrimary,
    required VoidCallback onManage,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isPrimary ? AppTheme.gold : AppTheme.warmBorder,
          width: isPrimary ? 2 : 1,
        ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppTheme.gold.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 方式图标
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppTheme.creamFill,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: TextStyle(fontSize: 28.sp),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              // 账号信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          method,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (isPrimary) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              '默认账号',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.gold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      account,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '姓名：$realName',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // 操作按钮
              GestureDetector(
                onTap: onManage,
                child: Icon(
                  Icons.more_vert_rounded,
                  color: AppTheme.textMuted,
                  size: 20.sp,
                ),
              ),
            ],
          ),
          if (!isPrimary) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppTheme.creamFill,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
                      '设为默认',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        side: BorderSide(
                          color: AppTheme.warmBorder,
                        ),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
                      '删除',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.danger,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 空��态提示
  Widget _buildEmptyBindMessage() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.warmBorder),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: AppTheme.sage,
            size: 36.sp,
          ),
          SizedBox(height: 10.h),
          Text(
            '已绑定支付宝账号',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '点击上方账号可进行管理',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// 可绑定的方式分组
  Widget _buildBindableMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '添加新账号',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        // 支付宝
        _buildBindMethodItem(
          method: '支付宝',
          icon: '🅰️',
          description: '支付宝官方账户',
          isAvailable: true,
          onTap: () => Get.toNamed(RouteNames.bindAlipay),
        ),
        SizedBox(height: 12.h),
        // 微信（暂不支持）
        _buildBindMethodItem(
          method: '微信',
          icon: '💚',
          description: '微信支付账户',
          isAvailable: false,
          onTap: () {},
        ),
        SizedBox(height: 12.h),
        // 银行卡（暂不支持）
        _buildBindMethodItem(
          method: '银行卡',
          icon: '🏦',
          description: '银行卡账户',
          isAvailable: false,
          onTap: () {},
        ),
      ],
    );
  }

  /// 绑定方式项��
  Widget _buildBindMethodItem({
    required String method,
    required String icon,
    required String description,
    required bool isAvailable,
    required VoidCallback onTap,
  }) {
     return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.6,
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isAvailable ? AppTheme.warmBorder : AppTheme.warmBorder.withValues(alpha: 0.3),
            ),
          ),
        child: Row(
          children: [
            // 方式图标
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: AppTheme.creamFill,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: TextStyle(fontSize: 24.sp),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // 方式信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // 状态指示
            if (isAvailable)
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppTheme.textMuted,
                size: 16.sp,
              )
            else
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '敬请期待',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
           ],
         ),
        ),
      ),
    );
  }

  /// 绑定规则提示
  Widget _buildBindingRulesTip() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppTheme.rose.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppTheme.rose.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '绑定规则',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          _buildRuleTip('• 每个支付宝账号仅可绑定一次'),
          SizedBox(height: 6.h),
          _buildRuleTip('• 绑定后可直接提现到账号'),
          SizedBox(height: 6.h),
          _buildRuleTip('• 提现时间为工作日 09:00-17:00'),
          SizedBox(height: 6.h),
          _buildRuleTip('• 提现金额需满足最低要求'),
          SizedBox(height: 6.h),
          _buildRuleTip('• 账号信息需与身份认证一致'),
        ],
      ),
    );
  }

  /// 规则项目
  Widget _buildRuleTip(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        color: AppTheme.textSecondary,
        height: 1.5,
      ),
    );
  }
}

