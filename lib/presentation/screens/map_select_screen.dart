import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:door_to_door_service/core/utils/screen_adapter.dart';
import 'package:door_to_door_service/core/services/location_service.dart';
import 'package:door_to_door_service/core/models/address_model.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:permission_handler/permission_handler.dart';

/// 地图选择地址页面
class MapSelectScreen extends StatefulWidget {
  const MapSelectScreen({super.key});

  @override
  State<MapSelectScreen> createState() => _MapSelectScreenState();
}

class _MapSelectScreenState extends State<MapSelectScreen> {
  BMFMapController? _mapController;
  BMFCoordinate? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = true;
  bool _isMapReady = false;
  BMFMarker? _currentMarker; // 保存当前标记对象，用于移除

  LocationService get _locationService => Get.find<LocationService>();

  @override
  void initState() {
    super.initState();
    _initLocationAndMap();
  }

  /// 初始化位置和地图
  Future<void> _initLocationAndMap() async {
    final status = await Permission.location.status;
    if (!status.isGranted) {
      final result = await Permission.location.request();
      if (!result.isGranted) {
        setState(() => _isLoading = false);
        Get.snackbar('提示', '需要定位权限才能使用地图选点功能');
        return;
      }
    }

    try {
      double? lat = _locationService.latitude;
      double? lng = _locationService.longitude;
      if (lat == null || lng == null) {
        final location = await _locationService.getLocationOnce();
        if (location != null) {
          lat = location.latitude;
          lng = location.longitude;
        }
      }
      final defaultLat = lat ?? 31.239508;
      final defaultLng = lng ?? 121.499718;

      setState(() {
        _selectedLocation = BMFCoordinate(defaultLat, defaultLng);
        _selectedAddress = _locationService.currentAddress ?? '当前位置';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('错误', '获取位置失败: $e');
    }
  }

  /// 地图创建完成回调
  void _onMapCreated(BMFMapController controller) {
    _mapController = controller;
    _isMapReady = true;

    if (_selectedLocation != null) {
      _addMarker(_selectedLocation!);
      // 移动地图到初始位置
      controller.updateMapOptions(BMFMapOptions(center: _selectedLocation));
    }

    // 地图空白区域点击
    controller.setMapOnClickedMapBlankCallback(callback: (BMFCoordinate point) {
      _onMapClicked(point);
    });

    // POI 点击
    controller.setMapOnClickedMapPoiCallback(callback: (BMFMapPoi mapPoi) {
      _onMapPoiClicked(mapPoi);
    });
  }

  /// 地图空白区域点击回调
  void _onMapClicked(BMFCoordinate point) {
    setState(() {
      _selectedLocation = point;
      _selectedAddress =
          '经度: ${point.longitude.toStringAsFixed(6)}, 纬度: ${point.latitude.toStringAsFixed(6)}';
    });
    _updateMarker(point);
  }

  /// POI 点击回调
  void _onMapPoiClicked(BMFMapPoi poi) {
    final point = poi.pt;
    setState(() {
      _selectedLocation = point;
      _selectedAddress = poi.text ?? '未知位置';
    });
    _updateMarker(point!);
    // 移动地图中心到该 POI
    _mapController?.updateMapOptions(BMFMapOptions(center: point));
  }

  /// 添加标记
  void _addMarker(BMFCoordinate point) {
    if (!_isMapReady) return;
    final marker = BMFMarker.icon(
      position: point,
      identifier: 'selected_marker',
      title: '选中位置',
      icon: 'assets/marker_icon.png',
    );
    _mapController?.addMarker(marker);
    _currentMarker = marker; // 保存引用以便后续移除
  }

  /// 更新标记（先移除旧标记，再添加新标记）
  void _updateMarker(BMFCoordinate point) {
    if (!_isMapReady) return;
    // 移除旧标记
    if (_currentMarker != null) {
      _mapController?.removeMarker(_currentMarker!);
    }
    // 添加新标记
    _addMarker(point);
  }

  /// 确认选择
  void _confirmSelection() {
    if (_selectedLocation == null) {
      Get.snackbar('提示', '请先在地图上选择位置');
      return;
    }

    final address = AddressModel(
      id: 'map_${DateTime.now().millisecondsSinceEpoch}',
      name: _selectedAddress,
      shortName: _selectedAddress.length > 20
          ? '${_selectedAddress.substring(0, 20)}...'
          : _selectedAddress,
      province: _locationService.currentProvince ?? '',
      city: _locationService.currentCity ?? '',
      district: _locationService.currentDistrict ?? '',
      street: _selectedAddress,
      latitude: _selectedLocation!.latitude,
      longitude: _selectedLocation!.longitude,
      isDefault: false,
    );

    Get.back(result: address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('选择位置', style: TextStyle(fontSize: 18.sp)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: BMFMapWidget(
                    onBMFMapCreated: _onMapCreated,
                    mapOptions: BMFMapOptions(
                      center: _selectedLocation ??
                          BMFCoordinate(39.908823, 116.397470),
                      zoomLevel: 15,
                      gesturesEnabled: true,
                      mapType: BMFMapType.Standard,
                    ),
                  ),
                ),
                _buildBottomPanel(),
              ],
            ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                  _selectedAddress,
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
