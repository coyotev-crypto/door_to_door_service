import 'package:door_to_door_service/core/themes/app_theme.dart';
import 'package:door_to_door_service/data/models/service_item.dart';
import 'package:door_to_door_service/presentation/controllers/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../widgets/section_header_widget.dart';

/// 下单页面 — 温润质感·臻享预约
class OrderCreateScreen extends GetView<OrderController> {
  const OrderCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        title: Text('确认下单',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              size: 20.sp, color: AppTheme.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final service = controller.service;
        if (service == null) {
          return const Center(
              child:
                  Text('服务信息加载失败', style: TextStyle(color: AppTheme.textMuted)));
        }
        return _buildForm(context, service);
      }),
    );
  }

  Widget _buildForm(BuildContext context, ServiceItem service) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildServiceHero(context, service),
          SizedBox(height: 28.h),
          const SectionHeaderWidget(title: '服务信息', badge: '详情'),
          SizedBox(height: 14.h),
          _buildInfoCard(service),
          SizedBox(height: 28.h),
          const SectionHeaderWidget(title: '地址与时间'),
          SizedBox(height: 14.h),
          _buildAddressWithContact(context),
          SizedBox(height: 14.h),
          _buildTimeSelector(context),
          SizedBox(height: 28.h),
          const SectionHeaderWidget(title: '备注'),
          SizedBox(height: 14.h),
          _buildRemarkField(),
          SizedBox(height: 28.h),
          _buildPriceReceipt(context, service),
          SizedBox(height: 32.h),
          _buildSubmitButton(),
          SizedBox(height: 16.h),
          _buildFooterHint(),
        ],
      ),
    );
  }

  /// 服务主视觉卡片
  Widget _buildServiceHero(BuildContext context, ServiceItem service) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
              color: AppTheme.gold.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          // 头像
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3), width: 2),
              boxShadow: [
                BoxShadow(
                    color: AppTheme.gold.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: service.avatar != null && service.avatar!.isNotEmpty
                ? Image.network(service.avatar!,
                    fit: BoxFit.cover,
                    cacheWidth: 256,
                    errorBuilder: (_, __, ___) => _avatarPlaceholder())
                : _avatarPlaceholder(),
          ),
          SizedBox(width: 16.w),
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name,
                    style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        height: 1.2)),
                SizedBox(height: 4.h),
                if (service.providerName != null &&
                    service.providerName!.isNotEmpty)
                  Text(service.providerName!,
                      style: TextStyle(
                          fontSize: 13.sp, color: AppTheme.textSecondary)),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 14.sp, color: AppTheme.gold),
                    SizedBox(width: 3.w),
                    Text('${service.rating}',
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary)),
                    if (service.orderCount != null) ...[
                      SizedBox(width: 10.w),
                      Text('${service.orderCount}单',
                          style: TextStyle(
                              fontSize: 12.sp, color: AppTheme.textMuted)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // 价格（响应式）
          Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('¥${controller.selectedPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.gold,
                          height: 1)),
                ],
              )),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      color: AppTheme.creamFill,
      child: Icon(Icons.spa_rounded,
          size: 32.sp, color: AppTheme.gold.withValues(alpha: 0.4)),
    );
  }

  /// 服务详情卡片 — 含时长选择
  Widget _buildInfoCard(ServiceItem service) {
    final durations = controller.availableDurations;
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
          Text('选择服务时长',
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
          SizedBox(height: 10.h),
          Obx(() => Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: durations.map((p) {
                  final mins = (p['durationMinutes'] as int?) ?? 60;
                  final price = double.tryParse(p['price']?.toString() ?? '') ?? 0;
                  final selected =
                      mins == controller.selectedDurationMinutes;
                  return GestureDetector(
                    onTap: () => controller.selectDuration(mins),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.gold.withValues(alpha: 0.1)
                            : AppTheme.creamBg,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: selected
                              ? AppTheme.gold
                              : AppTheme.warmBorder,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text('$mins 分钟',
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? AppTheme.gold
                                      : AppTheme.textPrimary)),
                          SizedBox(height: 2.h),
                          Text('¥${price.toStringAsFixed(0)}',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: selected
                                      ? AppTheme.amber
                                      : AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )),
          if (service.travelFeeValue != null && service.travelFeeValue! > 0) ...[
            SizedBox(height: 14.h),
            _divider(),
            _infoRow('出行费', '¥${service.travelFee!}/公里'),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted)),
          Text(value,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 16.h, thickness: 0.5, color: AppTheme.warmBorder);
  }

  /// 地址选择器
  /// 地址与联系人 — 统一卡片
  Widget _buildAddressWithContact(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.selectAddress(),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppTheme.warmBorder),
        ),
        child: Obx(() {
          final address = controller.selectedAddress;
          final hasAddress = address != null;
          return Column(
            children: [
              // 地址行
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: const Icon(Icons.location_on_rounded,
                        color: AppTheme.gold, size: 22),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hasAddress ? '服务地址' : '选择服务地址',
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary)),
                        SizedBox(height: 2.h),
                        Text(
                          hasAddress
                              ? address.name
                              : '点击选择您的服务地址',
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: hasAddress
                                  ? AppTheme.textSecondary
                                  : AppTheme.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 22.sp, color: AppTheme.textMuted),
                ],
              ),
              // 联系人信息（选择地址后展示）
              if (hasAddress) ...[
                SizedBox(height: 14.h),
                Container(height: 1, color: AppTheme.warmBorder),
                SizedBox(height: 14.h),
                _contactDisplayRow(
                  icon: Icons.person_outline_rounded,
                  label: '联系人',
                  value: controller.contactNameController.text.isEmpty
                      ? '未填写'
                      : controller.contactNameController.text,
                ),
                SizedBox(height: 10.h),
                _contactDisplayRow(
                  icon: Icons.phone_outlined,
                  label: '联系电话',
                  value: controller.contactPhoneController.text.isEmpty
                      ? '未填写'
                      : controller.contactPhoneController.text,
                ),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _contactDisplayRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final hasValue = value != '未填写';
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: hasValue ? AppTheme.gold : AppTheme.textMuted),
        SizedBox(width: 10.w),
        Text('$label  ',
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted)),
        Text(value,
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: hasValue ? AppTheme.textPrimary : AppTheme.textMuted)),
      ],
    );
  }

  /// 日期 + 时间选择器
  Widget _buildTimeSelector(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _timePickerCard(
          icon: Icons.calendar_today_rounded,
          label: '服务日期',
          value: controller.selectedDate,
          placeholder: '选择日期',
          onTap: () => controller.pickDate(),
        )),
        SizedBox(width: 12.w),
        Expanded(
            child: _timePickerCard(
          icon: Icons.access_time_rounded,
          label: '服务时间',
          value: controller.selectedTime,
          placeholder: '选择时间',
          onTap: () => controller.pickTime(),
        )),
      ],
    );
  }

  Widget _timePickerCard({
    required IconData icon,
    required String label,
    required String value,
    required String placeholder,
    required VoidCallback onTap,
  }) {
    final hasValue = value.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: hasValue ? AppTheme.gold.withValues(alpha: 0.3) : AppTheme.warmBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, size: 16.sp, color: AppTheme.gold),
                ),
                SizedBox(width: 8.w),
                Text(label,
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted)),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              hasValue ? value : placeholder,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: hasValue ? FontWeight.w700 : FontWeight.w400,
                color: hasValue ? AppTheme.textPrimary : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 备注输入
  Widget _buildRemarkField() {
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
          Text('订单备注',
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller.remarkController,
            maxLines: 3,
            style: TextStyle(fontSize: 15.sp, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: '如有特殊要求请备注（选填）',
              hintStyle: TextStyle(fontSize: 14.sp, color: AppTheme.textMuted),
              filled: true,
              fillColor: AppTheme.creamBg,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              prefixIcon:
                  Icon(Icons.edit_note_rounded, size: 18.sp, color: AppTheme.gold),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: AppTheme.gold, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 价格汇总 — 收据风格
  Widget _buildPriceReceipt(BuildContext context, ServiceItem service) {
    return Obx(() {
      final price = controller.selectedPrice;
      final total = controller.totalPrice;
      final mins = controller.selectedDurationMinutes;
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
                  child: Text('费用明细',
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMuted,
                          letterSpacing: 2)),
                ),
                Expanded(child: _dashedLine()),
              ],
            ),
            SizedBox(height: 18.h),
            _priceLine('服务费用 ($mins 分钟)', price),
            if (service.travelFeeValue != null && service.travelFeeValue! > 0)
              _priceLine('出行费用', service.travelFeeValue!),
            SizedBox(height: 12.h),
            Container(height: 1, color: AppTheme.warmBorder),
            SizedBox(height: 14.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('合计',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('¥',
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.gold)),
                    Text(total,
                        style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.gold,
                            height: 1)),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _priceLine(String label, double amount) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary)),
          Text('¥${amount.toStringAsFixed(0)}',
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
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
            (_) => Container(width: dashWidth, height: 1, color: AppTheme.warmBorder),
          ),
        );
      },
    );
  }

  /// 提交按钮
  Widget _buildSubmitButton() {
    return Obx(() {
      final loading = controller.isSubmitting;
      return GestureDetector(
        onTap: loading ? null : controller.submit,
        child: Container(
          height: 56.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.gold, AppTheme.amber],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.gold.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Center(
            child: loading
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.spa_rounded, size: 20.sp, color: Colors.white),
                      SizedBox(width: 10.w),
                      Text('确认预约',
                          style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 2)),
                    ],
                  ),
          ),
        ),
      );
    });
  }

  /// 底部提示
  Widget _buildFooterHint() {
    return Center(
      child: Text('提交即表示您同意服务条款与预约协议',
          style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted)),
    );
  }
}
