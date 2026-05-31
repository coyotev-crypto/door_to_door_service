import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../core/themes/app_theme.dart';
import '../../controllers/account_security_controller.dart';
import '../../../data/models/login_device_model.dart';

/// 登录设备管理 — 温润质感
class LoginDevicesScreen extends GetView<AccountSecurityController> {
  const LoginDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        title: Text('登录设备管理', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        centerTitle: true,
        backgroundColor: Colors.white, elevation: 0, scrolledUnderElevation: 0.5,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, size: 20.sp, color: AppTheme.textPrimary), onPressed: () => Get.back()),
      ),
      body: Obx(() {
        if (controller.isLoadingDevices) return const Center(child: CircularProgressIndicator(color: AppTheme.gold, strokeWidth: 2.5));
        if (controller.devices.isEmpty) return _emptyState();
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 40.h),
          itemCount: controller.devices.length,
          itemBuilder: (_, i) => _DeviceCard(device: controller.devices[i], onRemove: () => _showRemoveDialog(context, controller.devices[i])),
        );
      }),
    );
  }

  Widget _emptyState() {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 72.w, height: 72.w, decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: 0.08), shape: BoxShape.circle), child: Icon(Icons.devices_rounded, size: 32.sp, color: AppTheme.textMuted)),
      SizedBox(height: 16.h),
      Text('暂无登录设备', style: TextStyle(fontSize: 15.sp, color: AppTheme.textMuted)),
    ]));
  }

  void _showRemoveDialog(BuildContext context, LoginDeviceModel device) {
    if (device.isCurrentDevice) {
      Get.snackbar('提示', '无法移除当前设备', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 48.w, height: 48.w, decoration: BoxDecoration(color: AppTheme.danger.withValues(alpha: 0.08), shape: BoxShape.circle), child: Icon(Icons.phone_android_rounded, size: 24.sp, color: AppTheme.danger)),
            SizedBox(height: 16.h),
            Text('移除设备', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            SizedBox(height: 8.h),
            Text('确定要移除 ${device.deviceName} 吗？', style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary)),
            SizedBox(height: 24.h),
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(height: 44.h, decoration: BoxDecoration(color: AppTheme.creamBg, borderRadius: BorderRadius.circular(12.r)), child: Center(child: Text('取消', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)))),
              )),
              SizedBox(width: 12.w),
              Expanded(child: GestureDetector(
                onTap: () { Get.back(); controller.removeLoginDevice(deviceId: device.id); },
                child: Container(height: 44.h, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.danger, AppTheme.danger.withValues(alpha: 0.85)]), borderRadius: BorderRadius.circular(12.r)), child: Center(child: Text('确定移除', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white)))),
              )),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final LoginDeviceModel device;
  final VoidCallback onRemove;

  const _DeviceCard({required this.device, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r), boxShadow: [BoxShadow(color: const Color(0xFF2D2A26).withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 40.w, height: 40.w, decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10.r)), child: Icon(_deviceIcon(device.deviceType), size: 20.sp, color: AppTheme.gold)),
          SizedBox(width: 12.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(device.deviceName, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            SizedBox(height: 2.h),
            Text(device.deviceTypeDisplayName, style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted)),
          ])),
          if (device.isCurrentDevice)
            Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h), decoration: BoxDecoration(color: AppTheme.sage.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r)), child: Text('当前', style: TextStyle(fontSize: 11.sp, color: AppTheme.sage, fontWeight: FontWeight.w600))),
        ]),
        if (device.ipAddress != null || device.location != null) ...[SizedBox(height: 10.h), Row(children: [Icon(Icons.location_on_outlined, size: 14.sp, color: AppTheme.textMuted), SizedBox(width: 4.w), Expanded(child: Text(device.location ?? device.ipAddress ?? '', style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted)))])],
        if (device.lastLoginTime != null) Padding(padding: EdgeInsets.only(top: 6.h), child: Row(children: [Icon(Icons.access_time, size: 14.sp, color: AppTheme.textMuted), SizedBox(width: 4.w), Text('最后登录: ${_formatTime(device.lastLoginTime!)}', style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted))])),
        if (!device.isCurrentDevice) ...[SizedBox(height: 12.h), SizedBox(width: double.infinity, child: GestureDetector(onTap: onRemove, child: Container(height: 40.h, decoration: BoxDecoration(color: AppTheme.danger.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10.r), border: Border.all(color: AppTheme.danger.withValues(alpha: 0.2))), child: Center(child: Text('移除设备', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppTheme.danger))))))],
      ]),
    );
  }

  IconData _deviceIcon(String t) {
    switch (t.toLowerCase()) {
      case 'android': return Icons.android;
      case 'ios': return Icons.phone_iphone;
      case 'web': return Icons.computer;
      default: return Icons.devices;
    }
  }

  static final Map<String, String> _tcache = {};
  static String _formatTime(DateTime dt) {
    final key = dt.toIso8601String();
    if (_tcache.containsKey(key)) return _tcache[key]!;
    final diff = DateTime.now().difference(dt);
    final r = diff.inDays == 0
        ? diff.inHours == 0 ? (diff.inMinutes == 0 ? '刚刚' : '${diff.inMinutes}分钟前') : '${diff.inHours}小时前'
        : diff.inDays == 1 ? '昨天 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
        : diff.inDays < 7 ? '${diff.inDays}天前'
        : '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    _tcache[key] = r;
    return r;
  }
}
