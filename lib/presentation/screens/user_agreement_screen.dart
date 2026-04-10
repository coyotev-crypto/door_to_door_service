import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_agreement_controller.dart';
import '../../core/utils/screen_adapter.dart';

class UserAgreementScreen extends StatelessWidget {
  const UserAgreementScreen({super.key});

  UserAgreementController get _controller => Get.find<UserAgreementController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('用户协议', style: TextStyle(fontSize: 18.sp)),
      ),
      body: SingleChildScrollView(
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
            Text(
              _controller.agreementContent,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
