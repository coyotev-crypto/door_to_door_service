
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:door_to_door_service/core/utils/screen_adapter.dart';
import 'package:door_to_door_service/core/models/address_model.dart';
import 'package:door_to_door_service/presentation/controllers/address_controller.dart';

/// 地址栏组件
/// 
/// 显示当前选中的地址，点击后跳转到地址选择页面
class AddressBarWidget extends StatelessWidget {
  /// 点击地址栏的回调
  final VoidCallback? onTap;

  const AddressBarWidget({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddressController>(
      init: AddressController(),
      builder: (controller) {
        final address = controller.selectedAddress.value;
        final displayText = _getDisplayText(address);

        return GestureDetector(
          onTap: onTap ?? () => Get.toNamed('/address/select'),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 18.sp,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20.sp,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 获取显示文本
  String _getDisplayText(AddressModel? address) {
    if (address == null) {
      return '请选择地址';
    }

    // 优先显示：区域 > 城市 > 完整地址
    if (address.shortName.isNotEmpty && address.shortName != address.name) {
      return address.shortName;
    }

    if (address.district.isNotEmpty) {
      return address.district;
    }

    if (address.city.isNotEmpty) {
      return address.city;
    }

    return address.name;
  }
}
