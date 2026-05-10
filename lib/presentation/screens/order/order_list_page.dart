import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../data/models/order_model.dart';
import '../../controllers/order_list_controller.dart';

/// 订单列表页面（服务商视角）
class OrderListPage extends GetView<OrderListController> {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_rounded,
                  size: 64.sp, color: Colors.grey[300]),
              SizedBox(height: 16.h),
              Text('暂无订单',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[500])),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () => controller.loadOrders(),
        child: ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            return _buildOrderCard(context, controller.orders[index]);
          },
        ),
      );
    });
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.serviceName ?? '服务订单',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: _statusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(order.statusText,
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: _statusColor(order.status),
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.person_outline, size: 14.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(order.contactName ?? '',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
              SizedBox(width: 16.w),
              Icon(Icons.phone_outlined, size: 14.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(order.contactPhone ?? '',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 14.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(order.addressName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
              ),
            ],
          ),
          if (order.serviceTime?.isNotEmpty == true) ...[
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Icons.access_time, size: 14.sp, color: Colors.grey),
                SizedBox(width: 4.w),
                Text(order.serviceTime!,
                    style:
                        TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
              ],
            ),
          ],
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.createTime ?? '',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[400])),
              Text('¥${order.totalPrice?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.grey;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
