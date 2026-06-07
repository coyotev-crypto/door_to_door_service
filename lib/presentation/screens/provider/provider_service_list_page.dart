import 'package:door_to_door_service/presentation/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../data/models/service_item.dart';
import '../../controllers/provider_service_list_controller.dart';

/// 服务管理列表页面 — 温润质感
class ProviderServiceListPage extends GetView<ProviderServiceListController> {
  const ProviderServiceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        title: Text('服务管理',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.gold, strokeWidth: 2.5));
        }
        if (controller.services.isEmpty) {
          return _buildEmptyView();
        }
        return _buildListView();
      }),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.06),
              shape: BoxShape.circle),
          child: Icon(Icons.room_service_rounded,
              size: 36.sp, color: AppTheme.textMuted),
        ),
        SizedBox(height: 16.h),
        Text('暂无服务',
            style:
                TextStyle(fontSize: 16.sp, color: AppTheme.textMuted)),
        SizedBox(height: 8.h),
        Text('点击下方按钮添加第一个服务',
            style: TextStyle(
                fontSize: 13.sp, color: AppTheme.textMuted)),
        SizedBox(height: 32.h),
        Container(
          padding: EdgeInsets.all(12.w),
          child: PrimaryButton(text: "新增服务",icon:Icons.add_rounded,onPressed: ()=> controller.navigateToCreate(),),
        ),
      ]),
    );
  }

  Widget _buildListView() {
    return Column(children: [
      Expanded(
        child: RefreshIndicator(
          onRefresh: () => controller.loadServices(),
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.services.length,
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _ServiceCard(service: controller.services[i],
                  onToggle: () =>
                      controller.toggleStatus(controller.services[i]),
                  onEdit: () =>
                      controller.navigateToEdit(controller.services[i])),
            ),
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: AppTheme.textPrimary.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, -2))
          ],
        ),
        child: PrimaryButton(text: "新增服务",icon:Icons.add_rounded,onPressed: ()=> controller.navigateToCreate(),),
        // child: _buildAddButton(),
      ),
    ]);
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceItem service;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const _ServiceCard(
      {required this.service, required this.onToggle, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final onShelf = service.status == 1;
    final rejected = service.isAuditRejected;

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
                color: AppTheme.textPrimary.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  width: 68.w,
                  height: 68.w,
                  color: AppTheme.creamBg,
                  child: service.avatar != null &&
                          service.avatar!.isNotEmpty
                      ? Image.network(service.avatar!,
                          fit: BoxFit.cover,
                          cacheWidth: 256,
                          errorBuilder: (_, __, ___) =>
                              _placeholder())
                      : _placeholder(),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color:
                                onShelf ? AppTheme.sage : AppTheme.textMuted,
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
                                  color: AppTheme.textPrimary)),
                        ),
                      ]),
                      SizedBox(height: 4.h),
                      if (service.providerName?.isNotEmpty == true)
                        Text(service.providerName!,
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: AppTheme.textMuted)),
                      SizedBox(height: 6.h),
                      Row(children: [
                        Text('¥${service.price}',
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.gold)),
                        if (service.categoryName != null) ...[
                          SizedBox(width: 10.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppTheme.gold.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(service.categoryName!,
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppTheme.gold,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ]),
                    ]),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: onShelf
                        ? AppTheme.danger.withValues(alpha: 0.06)
                        : AppTheme.sage.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(onShelf ? '下架' : '上架',
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: onShelf
                              ? AppTheme.danger
                              : AppTheme.sage)),
                ),
              ),
            ]),
            // 审核驳回提示
            if (rejected) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10.r),
                  border:
                      Border.all(color: AppTheme.danger.withValues(alpha: 0.15)),
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 16.sp, color: AppTheme.danger),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('审核驳回',
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.danger)),
                              if (service.auditRemark?.isNotEmpty ==
                                  true) ...[
                                SizedBox(height: 4.h),
                                Text(service.auditRemark!,
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppTheme.textSecondary,
                                        height: 1.4)),
                              ],
                            ]),
                      ),
                    ]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Icon(Icons.spa_rounded,
      size: 28.sp, color: AppTheme.textMuted.withValues(alpha: 0.3));
}
