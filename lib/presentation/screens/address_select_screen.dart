import 'package:door_to_door_service/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:door_to_door_service/core/utils/screen_adapter.dart';
import 'package:door_to_door_service/presentation/controllers/address_controller.dart';
import 'package:door_to_door_service/core/models/address_model.dart';

/// 地址选择页面
///
/// 提供地址选择功能，包括当前位置、历史地址、热门区域等
class AddressSelectScreen extends StatelessWidget {
  const AddressSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddressController());

    return Scaffold(
      appBar: AppBar(
        title: Text('选择地址', style: TextStyle(fontSize: 18.sp)),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Get.toNamed(RouteNames.addressManage),
            child: Text(
              '管理',
              style: TextStyle(
                fontSize: 15.sp,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索框
          _buildSearchBar(controller),

          // 地址列表
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                children: [
                  // 当前位置
                  _buildCurrentLocation(controller),
                  SizedBox(height: 16.h),
                  // 搜索结果或历史地址
                  if (controller.searchQuery.value.isNotEmpty)
                    _buildSearchResults(controller)
                  else
                    _buildHistoryAddresses(controller),
                  SizedBox(height: 16.h),
                  // 从地图选择（占位）
                  _buildMapSelectButton(),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 构建搜索框
  Widget _buildSearchBar(AddressController controller) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 20.sp, color: Colors.grey[600]),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索地址',
                hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                border: InputBorder.none,
              ),
              style: TextStyle(fontSize: 14.sp),
              onChanged: controller.searchAddresses,
            ),
          ),
          if (controller.searchQuery.value.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, size: 20.sp, color: Colors.grey[600]),
              onPressed: controller.clearSearch,
            ),
        ],
      ),
    );
  }

  /// 构建当前位置
  Widget _buildCurrentLocation(AddressController controller) {
    final currentLocation = controller.getCurrentLocationAddress();

    if (currentLocation == null) {
      return const SizedBox.shrink();
    }

    return _buildAddressItem(
      address: currentLocation,
      onTap: () => controller.selectAddress(currentLocation),
      isCurrentLocation: true,
    );
  }

  /// 构建搜索结果
  Widget _buildSearchResults(AddressController controller) {
    if (controller.searchResults.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Center(
          child: Text(
            '未找到相关地址',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '搜索结果',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        ...controller.searchResults.map(
          (address) => _buildAddressItem(
            address: address,
            onTap: () => controller.selectAddress(address),
          ),
        ),
      ],
    );
  }

  /// 构建历史地址
  Widget _buildHistoryAddresses(AddressController controller) {
    if (controller.addresses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '历史地址',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        ...controller.addresses.map(
          (address) => _buildAddressItem(
            address: address,
            onTap: () => controller.selectAddress(address),
            isDefault: address.isDefault,
          ),
        ),
      ],
    );
  }

  /// 构建地址项
  Widget _buildAddressItem({
    required AddressModel address,
    required VoidCallback onTap,
    bool isCurrentLocation = false,
    bool isDefault = false,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: Icon(
          isCurrentLocation ? Icons.my_location : Icons.location_on,
          color: isCurrentLocation
              ? Colors.blue
              : (isDefault ? Colors.orange : Colors.grey[600]),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                address.shortName,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isDefault)
              Container(
                margin: EdgeInsets.only(left: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '默认',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.orange,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          address.street,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }

  /// 构建地图选择按钮
  Widget _buildMapSelectButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton.icon(
        onPressed: () async {
          // 跳转到地图选择页面
          final result = await Get.toNamed('/map/select');

          // 如果用户选择了地址，则选择该地址
          if (result != null && result is AddressModel) {
            final controller = Get.find<AddressController>();
            await controller.selectAddress(result);
          }
        },
        icon: Icon(Icons.map, size: 20.sp),
        label: Text(
          '从地图选择',
          style: TextStyle(fontSize: 15.sp),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[100],
          foregroundColor: Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
        ),
      ),
    );
  }
}
