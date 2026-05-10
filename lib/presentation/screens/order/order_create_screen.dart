import 'package:door_to_door_service/data/models/service_item.dart';
import 'package:door_to_door_service/presentation/controllers/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/primary_input_field.dart';

/// 下单页面
class OrderCreateScreen extends GetView<OrderController> {
  const OrderCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      appBar: AppBar(
        title: Text(
          '确认下单',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0, scrolledUnderElevation: 0.5,
      ),
      body: Obx(() {
        final service = controller.service;
        if (service == null) {
          return const Center(child: Text('服务信息加载失败'));
        }
        return _buildForm(context, service);
      }),
    );
  }

  Widget _buildForm(BuildContext context, ServiceItem service) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildServiceInfoCard(context, service),
          SizedBox(height: 24.h),
          _buildSectionTitle('地址信息'),
          SizedBox(height: 12.h),
          _buildAddressSelector(context),
          SizedBox(height: 24.h),
          _buildSectionTitle('服务时间'),
          SizedBox(height: 12.h),
          _buildTimeSelector(context),
          SizedBox(height: 16.h),
          PrimaryInputField(
            label: '联系人',
            hintText: '请输入联系人姓名',
            controller: controller.contactNameController,
          ),
          SizedBox(height: 16.h),
          PrimaryInputField(
            label: '联系电话',
            hintText: '请输入联系电话',
            keyboardType: TextInputType.phone,
            controller: controller.contactPhoneController,
          ),
          SizedBox(height: 24.h),
          _buildSectionTitle('备注'),
          SizedBox(height: 12.h),
          PrimaryInputField(
            label: '订单备注',
            hintText: '如有特殊要求请备注（选填）',
            controller: controller.remarkController,
            maxLines: 3,
          ),
          SizedBox(height: 24.h),
          _buildPriceSummary(context, service),
          SizedBox(height: 32.h),
          Obx(() => PrimaryButton(
                text: '提交订单',
                isLoading: controller.isSubmitting,
                onPressed: controller.submit,
              )),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  /// 服务信息卡片（只读）
  Widget _buildServiceInfoCard(BuildContext context, ServiceItem service) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7F4),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE8E2D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  service.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                '¥${service.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                service.providerName ?? '',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
              ),
              const Spacer(),
              if (service.travelFee != null)
                Text(
                  '出行费 ¥${service.travelFee!.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 地址选择器
  Widget _buildAddressSelector(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.selectAddress(),
      child: Container(
        width: double.infinity,
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8.r),
          color: const Color(0xFFF9F7F4),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on_rounded,
                color: Theme.of(context).primaryColor, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Obx(() {
                final address = controller.selectedAddress;
                if (address != null) {
                  return Text(
                    address.name,
                    style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                }
                return Text(
                  '请选择服务地址',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                );
              }),
            ),
            Icon(Icons.chevron_right_rounded, size: 20.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// 价格汇总
  Widget _buildPriceSummary(BuildContext context, ServiceItem service) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7F4),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE8E2D8)),
      ),
      child: Column(
        children: [
          _buildPriceRow('服务价格', service.price),
          if (service.travelFee != null)
            _buildPriceRow('出行费', service.travelFee!),
          Divider(height: 24.h, color: Colors.grey[300]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '合计',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '¥${controller.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double price) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
          Text('¥${price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 14.sp, color: Colors.black87)),
        ],
      ),
    );
  }

  /// 日期 + 时间选择器
  Widget _buildTimeSelector(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => controller.pickDate(),
            child: Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8.r),
                color: const Color(0xFFF9F7F4),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 18.sp, color: Colors.grey[500]),
                  SizedBox(width: 6.w),
                  Obx(() => Text(
                        controller.selectedDate.isEmpty
                            ? '选择日期'
                            : controller.selectedDate,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: controller.selectedDate.isEmpty
                              ? Colors.grey[500]
                              : Colors.black87,
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: GestureDetector(
            onTap: () => controller.pickTime(),
            child: Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8.r),
                color: const Color(0xFFF9F7F4),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 18.sp, color: Colors.grey[500]),
                  SizedBox(width: 6.w),
                  Obx(() => Text(
                        controller.selectedTime.isEmpty
                            ? '选择时间'
                            : controller.selectedTime,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: controller.selectedTime.isEmpty
                              ? Colors.grey[500]
                              : Colors.black87,
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
