import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import '../controllers/user_agreement_controller.dart';
import '../../core/utils/screen_adapter.dart';

/// 用户协议页面
///
/// 用于展示应用的用户协议内容，支持HTML格式的内容展示
class UserAgreementScreen extends GetWidget<UserAgreementController> {
  const UserAgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('用户协议', style: TextStyle(fontSize: 18.sp)),
      ),
      body: Obx(() {
        // 显示加载状态
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // 显示用户协议内容
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '用户协议',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              Html(
                data: controller.agreementContent,
                style: {
                  "body": Style(
                    fontSize: FontSize(14.sp),
                    lineHeight: const LineHeight(1.5),
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                  ),
                  "p": Style(
                    margin: Margins.only(bottom: 10.h),
                  ),
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
