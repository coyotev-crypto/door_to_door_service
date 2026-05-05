import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import '../../controllers/privacy_policy_controller.dart';
import '../../../core/utils/screen_adapter.dart';

/// 隐私政策页面
///
/// 用于展示应用的隐私政策内容，支持HTML格式的内容展示
class PrivacyPolicyScreen extends GetWidget<PrivacyPolicyController> {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('隐私政策', style: TextStyle(fontSize: 18.sp)),
      ),
      body: Obx(() {
        // 显示加载状态
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // 显示隐私政策内容
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '隐私政策',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              Html(
                data: controller.policyContent,
              ),
            ],
          ),
        );
      }),
    );
  }
}
