import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import '../controllers/privacy_policy_controller.dart';
import '../../core/utils/screen_adapter.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final PrivacyPolicyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(PrivacyPolicyController());
    // 加载隐私政策
    _controller.loadPrivacyPolicy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('隐私政策', style: TextStyle(fontSize: 18.sp)),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

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
                  data: _controller.policyContent,
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
        },
      ),
    );
  }
}
