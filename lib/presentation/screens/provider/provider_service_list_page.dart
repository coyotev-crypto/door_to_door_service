import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../data/models/service_item.dart';
import '../../controllers/provider_service_list_controller.dart';
import '../../widgets/primary_button.dart';

/// 服务管理列表页面
class ProviderServiceListPage extends GetView<ProviderServiceListController> {
  const ProviderServiceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '服务管理',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.services.isEmpty) {
          return _buildEmptyView(context);
        }
        return _buildListView(context);
      }),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.room_service_rounded,
              size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            '暂无服务',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[500]),
          ),
          SizedBox(height: 24.h),
          _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => controller.loadServices(),
            child: ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: controller.services.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return _buildServiceCard(context, controller.services[index]);
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16.w),
          child: _buildAddButton(context),
        ),
      ],
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceItem service) {
    final isOnShelf = service.status == 1;
    return GestureDetector(
      onTap: () => controller.navigateToEdit(service),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: BoxDecoration(
                          color: isOnShelf
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300]!,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
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
                      GestureDetector(
                        onTap: () => controller.toggleStatus(service),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: isOnShelf
                                ? Colors.red.withOpacity(0.08)
                                : Colors.green.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: isOnShelf
                                  ? Colors.red.withOpacity(0.3)
                                  : Colors.green.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            isOnShelf ? '下架' : '上架',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isOnShelf ? Colors.red : Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Text(
                        '¥${service.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      if (service.originalPrice != null) ...[
                        SizedBox(width: 8.w),
                        Text(
                          '¥${service.originalPrice!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[400],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    service.providerName ?? '',
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
                  ),
                  if (service.categoryName != null) ...[
                    SizedBox(height: 4.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        service.categoryName!,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right_rounded, size: 20.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return PrimaryButton(
      text: '新增服务',
      icon: Icons.add_rounded,
      onPressed: () => controller.navigateToCreate(),
      width: double.infinity,
    );
  }
}
