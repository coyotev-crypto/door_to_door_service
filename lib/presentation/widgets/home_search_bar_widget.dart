import 'package:door_to_door_service/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/screen_adapter.dart';
import '../../core/services/location_service.dart';

class HomeSearchBarWidget extends StatefulWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onVoiceSearch;
  final VoidCallback? onScanSearch;

  const HomeSearchBarWidget({
    super.key,
    this.onSearchTap,
    this.onVoiceSearch,
    this.onScanSearch,
  });

  @override
  State<HomeSearchBarWidget> createState() => _HomeSearchBarWidgetState();
}

class _HomeSearchBarWidgetState extends State<HomeSearchBarWidget> {
  final LocationService _locationService = Get.find<LocationService>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // 城市显示
          Obx(() {
            final cityName = _locationService.currentCity ?? '北京';
            return GestureDetector(
              onTap: () {
                Get.toNamed(RouteNames.addressSelect);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      cityName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(width: 12.w),
          // 搜索框
          Expanded(
            child: GestureDetector(
              onTap: widget.onSearchTap,
              child: Container(
                height: 40.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      size: 20.sp,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '搜索服务',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // 语音搜索按钮
          if (widget.onVoiceSearch != null)
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: IconButton(
                onPressed: widget.onVoiceSearch,
                icon: Icon(
                  Icons.mic_rounded,
                  size: 20.sp,
                  color: Colors.grey[600],
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          SizedBox(width: 8.w),
          // 扫码搜索按钮
          if (widget.onScanSearch != null)
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: IconButton(
                onPressed: widget.onScanSearch,
                icon: Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 20.sp,
                  color: Colors.grey[600],
                ),
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    );
  }
}
