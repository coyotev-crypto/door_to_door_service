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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('服务管理',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
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
          Container(
            width: 80.w,
            height: 80.w,
            decoration:
                BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: Icon(Icons.room_service_rounded,
                size: 36.sp, color: Colors.grey[300]),
          ),
          SizedBox(height: 16.h),
          Text('暂无服务',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[500])),
          SizedBox(height: 8.h),
          Text('点击下方按钮添加第一个服务',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[400])),
          SizedBox(height: 32.h),
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
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: controller.services.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _buildServiceCard(context, controller.services[index]),
                );
              },
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, -2))
            ],
          ),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              // 服务图片
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  width: 72.w,
                  height: 72.w,
                  color: Colors.grey[100],
                  child: service.avatar != null && service.avatar!.isNotEmpty
                      ? Image.network(service.avatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(Icons.spa_rounded,
                              size: 28.sp, color: Colors.grey[300]))
                      : Icon(Icons.spa_rounded,
                          size: 28.sp, color: Colors.grey[300]),
                ),
              ),
              SizedBox(width: 14.w),
              // 信息区
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: BoxDecoration(
                            color: isOnShelf
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300]!,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(service.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87)),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(service.providerName ?? '',
                        style: TextStyle(
                            fontSize: 12.sp, color: Colors.grey[500])),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Text('¥${service.price.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor)),
                        if (service.categoryName != null) ...[
                          SizedBox(width: 10.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.06),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(service.categoryName!,
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Theme.of(context).primaryColor)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              // 上下架按钮
              GestureDetector(
                onTap: () => controller.toggleStatus(service),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isOnShelf
                        ? Colors.red.withOpacity(0.06)
                        : Colors.green.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(isOnShelf ? '下架' : '上架',
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: isOnShelf ? Colors.red[400] : Colors.green)),
                ),
              ),
            ],
          ),
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
