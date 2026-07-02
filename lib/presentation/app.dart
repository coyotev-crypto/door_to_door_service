import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/services/location_service.dart';
import '../routes/app_pages.dart';
import '../core/themes/app_theme.dart';
import '../core/utils/screen_adapter.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize:
          const Size(ScreenAdapter.designWidth, ScreenAdapter.designHeight),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Door To Door Service',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: AppPages.initial,
          initialBinding: BindingsBuilder(() {
            if (!Get.isRegistered<LocationService>()) {
              Get.put(LocationService(), permanent: true);
            }
          }),
          getPages: AppPages.routes,
          navigatorKey: navigatorKey,
          builder: (context, child) {
            return Overlay(
              key: overlayKey,
              initialEntries: [
                OverlayEntry(
                  builder: (context) => child ?? const SizedBox.shrink(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
