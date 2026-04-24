
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:door_to_door_service/core/utils/screen_adapter.dart';
import 'package:door_to_door_service/presentation/controllers/address_controller.dart';
import 'package:door_to_door_service/core/models/address_model.dart';

/// 地址管理页面
/// 
/// 提供地址列表管理功能，包括增删改查和设置默认地址
class AddressManageScreen extends StatelessWidget {
  const AddressManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddressController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('地址管理', style: TextStyle(fontSize: 18.sp)),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.addresses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off_outlined,
                  size: 64.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  '暂无地址',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.addresses.length,
            itemBuilder: (context, index) {
              final address = controller.addresses[index];
              return _buildAddressItem(address, controller);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/address/edit')?.then((_) {
          controller.refresh();
        }),
        icon: Icon(Icons.add, size: 20.sp),
        label: Text(
          '新增地址',
          style: TextStyle(fontSize: 15.sp),
        ),
      ),
    );
  }

  /// 构建地址项
  Widget _buildAddressItem(AddressModel address, AddressController controller) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () => Get.toNamed(
          '/address/edit',
          arguments: {'address': address},
        )?.then((_) {
          controller.refresh();
        }),
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
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
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '默认',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 8.h),

              // 详细地址
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      address.street,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (address.contactName != null || address.contactPhone != null)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${address.contactName ?? ''} ${address.contactPhone ?? ''}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 12.h),

              // 操作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 设置默认地址按钮
                  if (!address.isDefault)
                    TextButton(
                      onPressed: () => _setDefaultAddress(address, controller),
                      child: Text(
                        '设为默认',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),

                  // 编辑按钮
                  TextButton.icon(
                    onPressed: () => Get.toNamed(
                      '/address/edit',
                      arguments: {'address': address},
                    )?.then((_) {
                      controller.refresh();
                    }),
                    icon: Icon(Icons.edit_outlined, size: 18.sp),
                    label: Text(
                      '编辑',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),

                  // 删除按钮
                  TextButton.icon(
                    onPressed: () => _deleteAddress(address, controller),
                    icon: Icon(Icons.delete_outline, size: 18.sp),
                    label: Text(
                      '删除',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    style: TextButton.styleFrom(
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

  /// 设置默认地址
  Future<void> _setDefaultAddress(
    AddressModel address,
    AddressController controller,
  ) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('设为默认地址'),
        content: Text('确定将"${address.shortName}"设为默认地址吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await controller.setDefaultAddress(address.id);
      if (success) {
        Get.snackbar(
          '成功',
          '已设置为默认地址',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          '失败',
          '设置默认地址失败',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  /// 删除地址
  Future<void> _deleteAddress(
    AddressModel address,
    AddressController controller,
  ) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('删除地址'),
        content: Text('确定删除"${address.shortName}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await controller.deleteAddress(address.id);
      if (success) {
        Get.snackbar(
          '成功',
          '地址已删除',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          '失败',
          '删除地址失败',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}
