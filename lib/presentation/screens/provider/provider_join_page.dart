import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../controllers/profile_controller.dart';

/// 服务商入驻页面
class ProviderJoinPage extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();

  ProviderJoinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('服务商入驻'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 24.h),
            _buildSteps(),
            SizedBox(height: 32.h),
            _buildBenefits(),
            SizedBox(height: 32.h),
            _buildRequirements(),
            SizedBox(height: 32.h),
            _buildStartButton(context),
          ],
        ),
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(Get.context!).primaryColor,
            Theme.of(Get.context!).primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '成为我们的服务商',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '加入我们，开启您的服务事业',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建入驻步骤
  Widget _buildSteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '入驻步骤',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16.h),
        _buildStepItem(
          step: 1,
          title: '提交资质材料',
          description: '上传身份证、从业资格证、健康证等必要材料',
        ),
        SizedBox(height: 16.h),
        _buildStepItem(
          step: 2,
          title: '添加技能认证',
          description: '选择您擅长的服务类型，上传相关技能证书',
        ),
        SizedBox(height: 16.h),
        _buildStepItem(
          step: 3,
          title: '等待审核',
          description: '我们会在1-3个工作日内完成审核',
        ),
        SizedBox(height: 16.h),
        _buildStepItem(
          step: 4,
          title: '开始接单',
          description: '审核通过后，即可开始接单提供服务',
        ),
      ],
    );
  }

  /// 构建步骤项
  Widget _buildStepItem({
    required int step,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).primaryColor,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建入驻优势
  Widget _buildBenefits() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars_rounded,
                color: Colors.blue[700],
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '入驻优势',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildBenefitItem('灵活的工作时间，自主安排'),
          SizedBox(height: 8.h),
          _buildBenefitItem('丰厚的服务报酬，多劳多得'),
          SizedBox(height: 8.h),
          _buildBenefitItem('专业的客服支持，解决难题'),
        ],
      ),
    );
  }

  /// 构建优势项
  Widget _buildBenefitItem(String text) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: Colors.blue[700],
          size: 16.sp,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.blue[900],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建入驻要求
  Widget _buildRequirements() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_rounded,
                color: Colors.orange[700],
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '入驻要求',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildRequirementItem('年满18周岁，具有完全民事行为能力'),
          SizedBox(height: 8.h),
          _buildRequirementItem('持有有效的身份证件'),
          SizedBox(height: 8.h),
          _buildRequirementItem('具备相关从业资格证书'),
          SizedBox(height: 8.h),
          _buildRequirementItem('身体健康，持有健康证'),
          SizedBox(height: 8.h),
          _buildRequirementItem('无不良信用记录'),
        ],
      ),
    );
  }

  /// 构建要求项
  Widget _buildRequirementItem(String text) {
    return Row(
      children: [
        Icon(
          Icons.arrow_right_rounded,
          color: Colors.orange[700],
          size: 16.sp,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.orange[900],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建开始按钮
  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => controller.navigateToProviderQualification(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Text(
          '立即开始',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
