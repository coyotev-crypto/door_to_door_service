import 'package:door_to_door_service/core/themes/app_theme.dart';
import 'package:door_to_door_service/data/models/order_model.dart';
import 'package:door_to_door_service/presentation/controllers/order_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../widgets/section_header_widget.dart';
import '../../widgets/user_avatar_widget.dart';
import '../../widgets/common_app_bar.dart';

/// 订单详情页面 — 温润质感·臻享预约
class OrderDetailScreen extends GetView<OrderDetailController> {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: const CommonAppBar(title: '订单详情'),
      body: Obx(() {
        final order = controller.order;
        if (order == null) {
          return const Center(
            child: Text('订单信息加载失败',
                style: TextStyle(color: AppTheme.textMuted)),
          );
        }
        return _buildDetail(context, order);
      }),
    );
  }

  Widget _buildDetail(BuildContext context, OrderModel order) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 订单状态卡片
          _buildStatusCard(order),
          SizedBox(height: 28.h),

          // 核销区域（已支付未完成时显示）
          if (order.shouldShowQRCode) ...[
            _buildQRCodeSection(order),
            SizedBox(height: 28.h),
          ],

          // 服务人员信息（如果有）
          if (order.providerName != null && order.providerName!.isNotEmpty) ...[
            _buildProviderCard(order),
            SizedBox(height: 28.h),
          ],

          // 服务信息
          const SectionHeaderWidget(title: '服务信息', badge: '详情'),
          SizedBox(height: 14.h),
          _buildServiceInfo(order),
          SizedBox(height: 28.h),

          // 地址和联系人
          const SectionHeaderWidget(title: '服务地址'),
          SizedBox(height: 14.h),
          _buildAddressSection(order),
          SizedBox(height: 28.h),

          // 订单备注
          if (order.remark != null && order.remark!.isNotEmpty) ...[
            const SectionHeaderWidget(title: '订单备注'),
            SizedBox(height: 14.h),
            _buildRemarkCard(order),
            SizedBox(height: 28.h),
          ],

          // 价格汇总
          _buildPriceReceipt(order),
          SizedBox(height: 28.h),

          // 订单时间信息
          _buildTimeline(order),
          SizedBox(height: 28.h),

          // 操作按钮
          _buildActionButtons(order),
        ],
      ),
    );
  }

  /// 订单状态卡片
  Widget _buildStatusCard(OrderModel order) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            order.statusColor.withValues(alpha: 0.08),
            order.statusColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: order.statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: order.statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              _getStatusIcon(order.status),
              size: 28.sp,
              color: order.statusColor,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.statusText,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: order.statusColor,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '订单号：${order.orderNo ?? ''}',
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

  /// 二维码核销区域
  Widget _buildQRCodeSection(OrderModel order) {
    final codeStatus = order.isVerificationCodeUsed
        ? '已核销'
        : order.isVerificationCodeExpired
            ? '核销码已过期'
            : null;
    final codeStatusColor = order.isVerificationCodeUsed
        ? AppTheme.sage
        : order.isVerificationCodeExpired
            ? AppTheme.danger
            : AppTheme.gold;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // 标题
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.qr_code_2_rounded,
                  size: 22.sp,
                  color: AppTheme.gold,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '核销码',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    codeStatus ?? '服务人员输入核销码完成订单',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: codeStatus == null
                          ? AppTheme.textMuted
                          : codeStatusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // 二维码区域（使用纯文本展示，实际应使用qr_flutter库）
          Container(
            width: 200.w,
            height: 200.w,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: AppTheme.warmBorder,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 这里应该使用 qr_flutter 包来生成真实二维码
                // 示例代码:
                // QrImage(
                //   data: order.verificationCode ?? '',
                //   version: QrVersions.auto,
                //   size: 200.w,
                // )
                // 暂时使用文字占位符
                Icon(
                  Icons.qr_code_2_rounded,
                  size: 80.sp,
                  color: AppTheme.gold.withValues(alpha: 0.3),
                ),
                SizedBox(height: 12.h),
                Text(
                  '核销码',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // 核销码文本（可复制）
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.creamBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '核销码',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppTheme.textMuted,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.verificationCode ?? '无',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.copyVerificationCode(
                          order.verificationCode ?? ''),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: AppTheme.gold.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '复制',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.gold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (order.verificationCodeExpireAt != null &&
                    order.verificationCodeExpireAt!.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    '有效期至 ${order.verificationCodeExpireAt}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
                if (codeStatus != null) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        order.isVerificationCodeUsed
                            ? Icons.check_circle_outline_rounded
                            : Icons.error_outline_rounded,
                        size: 14.sp,
                        color: codeStatusColor,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        codeStatus,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: codeStatusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // 提示信息
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16.sp,
                  color: AppTheme.gold,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '请将此核销码展示给服务人员，以完成订单核销',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.gold,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 服务人员卡片
  Widget _buildProviderCard(OrderModel order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.warmBorder),
      ),
      child: Row(
        children: [
          UserAvatarWidget(
            avatarUrl: order.providerAvatar,
            username: order.providerName ?? '服务人员',
            size: 56.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.providerName ?? '服务人员',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                if (order.providerPhone != null) ...[
                  Text(
                    order.providerPhone!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: () => controller.callProvider(order.providerPhone ?? ''),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.phone_rounded,
                size: 20.sp,
                color: AppTheme.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 服务信息
  Widget _buildServiceInfo(OrderModel order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.warmBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.serviceName ?? '服务',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 14.h),
          _infoRow('服务时长', '${order.durationMinutes ?? 60} 分钟'),
          _infoRow('服务费用', '¥${order.servicePrice ?? '0'}'),
          if (order.travelFeeValue != null && order.travelFeeValue! > 0)
            _infoRow('出行费用', '¥${order.travelFee ?? '0'}'),
        ],
      ),
    );
  }

  /// 地址信息
  Widget _buildAddressSection(OrderModel order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.warmBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 20.sp,
                  color: AppTheme.gold,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '服务地址',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      order.addressName ?? '未提供',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Container(height: 1, color: AppTheme.warmBorder),
          SizedBox(height: 14.h),
          _contactRow(Icons.person_outline_rounded, '联系人', order.contactName),
          SizedBox(height: 10.h),
          _contactRow(Icons.phone_outlined, '电话', order.contactPhone),
        ],
      ),
    );
  }

  /// 备注卡片
  Widget _buildRemarkCard(OrderModel order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.warmBorder),
      ),
      child: Text(
        order.remark ?? '',
        style: TextStyle(
          fontSize: 14.sp,
          color: AppTheme.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }

  /// 价格汇总
  Widget _buildPriceReceipt(OrderModel order) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.warmBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _dashedLine()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Text(
                  '费用明细',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Expanded(child: _dashedLine()),
            ],
          ),
          SizedBox(height: 18.h),
          _priceLine('服务费用', double.parse(order.servicePrice ?? '0')),
          if (order.travelFeeValue != null && order.travelFeeValue! > 0)
            _priceLine('出行费用', order.travelFeeValue!),
          SizedBox(height: 12.h),
          Container(height: 1, color: AppTheme.warmBorder),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '合计',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '¥',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.gold,
                    ),
                  ),
                  Text(
                    order.totalPrice ?? '0',
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.gold,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 时间轴
  Widget _buildTimeline(OrderModel order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.warmBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '订单时间',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
            ),
          ),
          SizedBox(height: 12.h),
          _timelineItem('创建时间', order.createTime),
          if (order.updateTime != null)
            _timelineItem('更新时间', order.updateTime),
          if (order.serviceTime != null)
            _timelineItem('服务时间', order.serviceTime),
        ],
      ),
    );
  }

  /// 操作按钮
  Widget _buildActionButtons(OrderModel order) {
    if (order.isCancelled) {
      return SizedBox.shrink();
    }

    return Row(
      children: [
        if (!order.isCompleted) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => controller.contactService(),
              child: Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppTheme.gold.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    '联系客服',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.gold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
        ],
        Expanded(
          child: GestureDetector(
            onTap: () => controller.shareOrder(order),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.gold, AppTheme.amber],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share_rounded, size: 16.sp, color: Colors.white),
                    SizedBox(width: 6.w),
                    Text(
                      '分享订单',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 辅助方法

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppTheme.gold),
        SizedBox(width: 10.w),
        Text(
          '$label  ',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textMuted,
          ),
        ),
        Text(
          value ?? '未提供',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: value != null ? AppTheme.textPrimary : AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _priceLine(String label, double amount) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary),
          ),
          Text(
            '¥${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashWidth = 4.w;
        final dashCount =
            (constraints.maxWidth / (dashWidth * 2)).floor().clamp(1, 100);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            dashCount,
            (_) => Container(
              width: dashWidth,
              height: 1,
              color: AppTheme.warmBorder,
            ),
          ),
        );
      },
    );
  }

  Widget _timelineItem(String label, String? time) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted),
          ),
          Text(
            time ?? '—',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icons.payment_rounded;
      case 1:
      case 2:
        return Icons.handshake_rounded;
      case 3:
      case 4:
        return Icons.location_history_rounded;
      case 5:
        return Icons.check_circle_rounded;
      case 6:
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}

