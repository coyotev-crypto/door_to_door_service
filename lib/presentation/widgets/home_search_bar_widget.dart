import 'package:door_to_door_service/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/screen_adapter.dart';
import '../../core/services/location_service.dart';
import '../../core/themes/app_theme.dart';

/// 首页搜索栏 — 温润质感风格
class HomeSearchBarWidget extends StatefulWidget {
  final VoidCallback? onSearchTap;

  const HomeSearchBarWidget({super.key, this.onSearchTap});

  @override
  State<HomeSearchBarWidget> createState() => _HomeSearchBarWidgetState();
}

class _HomeSearchBarWidgetState extends State<HomeSearchBarWidget> {
  final LocationService _locationService = Get.find<LocationService>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
      child: Row(
        children: [
          // 城市选择
          GestureDetector(
            onTap: () => Get.toNamed(RouteNames.addressSelect),
            child: Obx(() {
              final city = _locationService.currentCity ?? '北京';
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_rounded, size: 18.sp, color: AppTheme.gold),
                  SizedBox(width: 2.w),
                  Text(city,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  SizedBox(width: 2.w),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 18.sp, color: AppTheme.textMuted),
                ],
              );
            }),
          ),
          SizedBox(width: 14.w),
          // 搜索框
          Expanded(
            child: GestureDetector(
              onTap: widget.onSearchTap,
              child: Container(
                height: 40.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0E8),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, size: 18.sp, color: AppTheme.textMuted),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text('搜索服务',
                          style: TextStyle(fontSize: 14.sp, color: AppTheme.textMuted)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
