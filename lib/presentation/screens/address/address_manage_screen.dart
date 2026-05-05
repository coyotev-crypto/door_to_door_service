import 'package:door_to_door_service/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:door_to_door_service/core/utils/screen_adapter.dart';
import 'package:door_to_door_service/core/utils/toast_util.dart';
import 'package:door_to_door_service/presentation/controllers/address_controller.dart';
import 'package:door_to_door_service/data/models/address_model.dart';

/// 地址管理页面
///
/// 提供地址列表管理功能，包括增删改查和设置默认地址
class AddressManageScreen extends StatelessWidget {
  const AddressManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddressController>();
    final themeColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '地址管理',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
              ),
            ),
          );
        }

        if (controller.addresses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off_outlined,
                  size: 80.sp,
                  color: themeColor,
                ),
                SizedBox(height: 24.h),
                Text(
                  '暂无地址',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 24.h),
                _buildAddButton(context, controller, themeColor),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refresh,
                color: themeColor,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: controller.addresses.length,
                  itemBuilder: (context, index) {
                    final address = controller.addresses[index];
                    return _buildAddressItem(
                        context, address, controller, themeColor);
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.w),
              child: _buildAddButton(context, controller, themeColor),
            ),
          ],
        );
      }),
    );
  }

  /// 构建地址项
  Widget _buildAddressItem(
    BuildContext context,
    AddressModel address,
    AddressController controller,
    Color themeColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: address.isDefault
              ? themeColor.withOpacity(0.3)
              : Colors.grey[200]!,
          width: address.isDefault ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.toNamed(
          RouteNames.addressEdit,
          arguments: {'address': address},
        )?.then((_) {
          controller.refresh();
        }),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 地址信息和默认标签
              Row(
                children: [
                  Expanded(
                    child: Text(
                      address.shortName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (address.isDefault)
                    Container(
                      margin: EdgeInsets.only(left: 8.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '默认',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: themeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 12.h),

              // 详细地址
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 20.sp,
                    color: themeColor,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      address.street,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (address.contactName != null || address.contactPhone != null)
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 20.sp,
                        color: themeColor,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${address.contactName ?? ''} ${address.contactPhone ?? ''}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 16.h),

              // 操作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 设置默认地址按钮
                  if (!address.isDefault)
                    TextButton(
                      onPressed: () =>
                          _setDefaultAddress(address, controller, themeColor),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: themeColor,
                      ),
                      child: Text(
                        '设为默认',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  SizedBox(width: 16.w),

                  // 编辑按钮
                  TextButton.icon(
                    onPressed: () => Get.toNamed(
                      RouteNames.addressEdit,
                      arguments: {'address': address},
                    )?.then((_) {
                      controller.refresh();
                    }),
                    icon: Icon(Icons.edit_outlined, size: 18.sp),
                    label: Text(
                      '编辑',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: Colors.grey[600],
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // 删除按钮
                  TextButton.icon(
                    onPressed: () =>
                        _deleteAddress(address, controller, themeColor),
                    icon: Icon(Icons.delete_outline, size: 18.sp),
                    label: Text(
                      '删除',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建新增地址按钮
  Widget _buildAddButton(
    BuildContext context,
    AddressController controller,
    Color themeColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h, left: 24.w, right: 24.w),
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(Get.context!).primaryColor,
            Theme.of(Get.context!).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(Get.context!).primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          Get.toNamed(RouteNames.addressEdit)?.then((_) {
            controller.refresh();
          });
        },
        icon: Icon(
          Icons.add_location_rounded,
          size: 20.sp,
          color: Colors.white,
        ),
        label: Text(
          '新增地址',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  /// 设置默认地址
  Future<void> _setDefaultAddress(
    AddressModel address,
    AddressController controller,
    Color themeColor,
  ) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(
          '设为默认地址',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: Text(
          '确定将"${address.shortName}"设为默认地址吗？',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: Colors.grey[600],
            ),
            child: Text(
              '取消',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: themeColor,
            ),
            child: Text(
              '确定',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await controller.setDefaultAddress(address.id);
      if (success) {
        ToastUtil.showSuccess('已设置为默认地址');
      } else {
        ToastUtil.showError('设置默认地址失败');
      }
    }
  }

  /// 删除地址
  Future<void> _deleteAddress(
    AddressModel address,
    AddressController controller,
    Color themeColor,
  ) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(
          '删除地址',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: Text(
          '确定删除"${address.shortName}"吗？',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: Colors.grey[600],
            ),
            child: Text(
              '取消',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: Colors.red,
            ),
            child: Text(
              '删除',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await controller.deleteAddress(address.id);
      if (success) {
        ToastUtil.showSuccess('地址已删除');
      } else {
        ToastUtil.showError('删除地址失败');
      }
    }
  }
}
