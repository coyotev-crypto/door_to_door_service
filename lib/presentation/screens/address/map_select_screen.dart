import 'package:door_to_door_service/core/utils/screen_adapter.dart';
import 'package:door_to_door_service/presentation/controllers/map_select_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:get/get.dart';

/// 地图选择地址页面
class MapSelectScreen extends StatefulWidget {
  const MapSelectScreen({super.key});

  @override
  State<MapSelectScreen> createState() => _MapSelectScreenState();
}

class _MapSelectScreenState extends State<MapSelectScreen> {
  late MapSelectController controller = Get.find<MapSelectController>();
  late Size screenSize;

  /// 地图创建完成回调
  void onBMFMapCreated(BMFMapController mapController) {
    controller.onBMFMapCreated(mapController);
  }

  /// 确认选择
  void _confirmSelection() async {
    final addressModel = await controller.confirmSelection();
    if (addressModel != null) {
      Get.back(result: addressModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return GetBuilder<MapSelectController>(
      init: controller,
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('选择位置', style: TextStyle(fontSize: 18.sp)),
            elevation: 0,
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    generateMap(),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildBottomPanel(),
                    ),
                  ],
                ),
        );
      },
    );
  }

  /// 创建地图
  SizedBox generateMap() {
    return SizedBox(
      height: screenSize.height,
      width: screenSize.width,
      child: BMFMapWidget(
        onBMFMapCreated: onBMFMapCreated,
        mapOptions: _initMapOptions(),
      ),
    );
  }

  /// 设置地图参数
  BMFMapOptions _initMapOptions() {
    BMFCoordinate center =
        controller.selectedLocation ?? BMFCoordinate(39.908823, 116.397470);
    BMFMapOptions mapOptions = BMFMapOptions(
        mapType: controller.mapType,
        zoomLevel: 17, // 增加默认缩放等级，以便更好地检索周边地址
        maxZoomLevel: 21,
        minZoomLevel: 4,
        center: center,
        gesturesEnabled: true);
    return mapOptions;
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on,
                  color: Theme.of(context).primaryColor, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  controller.selectedAddress,
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: _confirmSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r)),
              ),
              child: Text('确认选择',
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
