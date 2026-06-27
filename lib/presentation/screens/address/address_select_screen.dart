import 'package:dtd/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dtd/core/utils/screen_adapter.dart';
import 'package:dtd/presentation/controllers/address_controller.dart';
import 'package:dtd/data/models/address_model.dart';
import '../../widgets/common_app_bar.dart';
import '../../../core/themes/app_theme.dart';

/// 地址选择页面
///
/// 提供地址选择功能，包括当前位置、历史地址、热门区域等
class AddressSelectScreen extends StatelessWidget {
  const AddressSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddressController());

    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: CommonAppBar(
        title: '选择地址',
        actions: [
          TextButton(
            onPressed: () => Get.toNamed(RouteNames.addressManage),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              '管理',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 搜索框
          _buildSearchBar(context, controller),
          SizedBox(height: 24.h),
          // 地址列表
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                );
              }
              return ListView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                children: [
                  // 当前位置
                  _buildCurrentLocation(context, controller),
                  SizedBox(height: 24.h),
                  // 搜索结果或历史地址
                  if (controller.searchQuery.value.isNotEmpty)
                    _buildSearchResults(context, controller)
                  else
                    _buildHistoryAddresses(context, controller),
                  SizedBox(height: 24.h),
                  // 从地图选择（占位）
                  _buildMapSelectButton(controller),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 构建搜索框
  Widget _buildSearchBar(BuildContext context, AddressController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 20.sp,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索地址',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
              onChanged: controller.searchAddresses,
            ),
          ),
          if (controller.searchQuery.value.isNotEmpty)
            TextButton(
              onPressed: controller.clearSearch,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Icon(
                Icons.clear,
                size: 20.sp,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  /// 构建当前位置
  Widget _buildCurrentLocation(
      BuildContext context, AddressController controller) {
    final currentLocation = controller.getCurrentLocationAddress();

    if (currentLocation == null) {
      return const SizedBox.shrink();
    }

    return _buildAddressItem(
      context: context,
      address: currentLocation,
      onTap: () => controller.selectAddress(currentLocation),
      isCurrentLocation: true,
    );
  }

  /// 构建搜索结果
  Widget _buildSearchResults(
      BuildContext context, AddressController controller) {
    if (controller.searchResults.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 48.sp,
                color: Colors.grey[400],
              ),
              SizedBox(height: 12.h),
              Text(
                '未找到相关地址',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
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
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        ...controller.searchResults.map(
          (address) => _buildAddressItem(
            context: context,
            address: address,
            onTap: () => controller.selectAddress(address),
          ),
        ),
      ],
    );
  }

  /// 构建历史地址
  Widget _buildHistoryAddresses(
      BuildContext context, AddressController controller) {
    if (controller.addresses.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.location_off,
                size: 48.sp,
                color: Colors.grey[400],
              ),
              SizedBox(height: 12.h),
              Text(
                '暂无历史地址',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '历史地址',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        ...controller.addresses.map(
          (address) => _buildAddressItem(
            context: context,
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
    required BuildContext context,
    required AddressModel address,
    required VoidCallback onTap,
    bool isCurrentLocation = false,
    bool isDefault = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(Get.context!).primaryColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isCurrentLocation
                    ? Theme.of(Get.context!).primaryColor.withValues(alpha: 0.1)
                    : (isDefault
                        ? Theme.of(Get.context!).primaryColor.withValues(alpha: 0.15)
                        : Colors.grey[100]),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                isCurrentLocation
                    ? Icons.my_location_rounded
                    : Icons.location_on_rounded,
                color: isCurrentLocation
                    ? Theme.of(Get.context!).primaryColor
                    : (isDefault
                        ? Theme.of(Get.context!).primaryColor
                        : Colors.grey[600]),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          address.shortName,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isDefault)
                        Container(
                          margin: EdgeInsets.only(left: 8.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(Get.context!)
                                .primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            '默认',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Theme.of(Get.context!).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    address.street,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // 收货人和电话
                  if (address.contactName != null ||
                      address.contactPhone != null)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        '${address.contactName ?? ''} ${address.contactPhone ?? ''}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建地图选择按钮
  Widget _buildMapSelectButton(AddressController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(Get.context!).primaryColor,
            Theme.of(Get.context!).primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(Get.context!).primaryColor.withValues(alpha: 0.3),
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
}
