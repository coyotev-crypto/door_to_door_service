import 'package:dtd/presentation/controllers/provider_qualification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:dtd/core/utils/screen_adapter.dart';
import 'package:dtd/presentation/widgets/certificate_level_selector.dart';
import 'package:dtd/presentation/widgets/gender_selector.dart';
import 'package:dtd/presentation/widgets/image_upload_card.dart';
import 'package:dtd/presentation/widgets/info_tip_widget.dart';
import 'package:dtd/presentation/widgets/primary_button.dart';
import 'package:dtd/presentation/widgets/primary_input_field.dart';
import '../../../core/themes/app_theme.dart';

/// 服务商资质材料页面
class ProviderQualificationPage
    extends GetView<ProviderQualificationController> {
  const ProviderQualificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: AppBar(
        title: Text(
          '资质材料',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 信息仅用于认证声明
              const InfoTipWidget(
                message: '您提供的个人信息将仅用于服务商资质认证，平台将严格保护您的隐私安全',
              ),
              SizedBox(height: 24.h),
              _buildSectionTitle('基本信息'),
              SizedBox(height: 12.h),
              PrimaryInputField(
                label: '姓名',
                hintText: '请输入姓名',
                controller: controller.nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入姓名';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              GenderSelector(
                selectedGender: controller.gender,
                onGenderChanged: (value) {
                  controller.updateGender(value);
                },
              ),
              SizedBox(height: 16.h),
              PrimaryInputField(
                controller: controller.phoneController,
                label: '联系方式',
                hintText: '请输入手机号码',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入联系方式';
                  }
                  if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                    return '请输入正确的手机号码';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              PrimaryInputField(
                controller: controller.ageController,
                label: '年龄',
                hintText: '请输入年龄',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入年龄';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 18 || age > 65) {
                    return '年龄必须在18-65岁之间';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              PrimaryInputField(
                controller: controller.emergencyContactController,
                label: '紧急联系人',
                hintText: '请输入紧急联系人姓名（选填）',
              ),
              SizedBox(height: 16.h),
              PrimaryInputField(
                controller: controller.emergencyPhoneController,
                label: '紧急联系人电话',
                hintText: '请输入紧急联系人电话（选填）',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                      return '请输入正确的手机号码';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.h),
              _buildSectionTitle('资质材料'),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => ImageUploadCard(
                          title: '本人近期照',
                          imageUrl: controller.recentPhoto,
                          onTap: () => controller.pickImage(
                              ProviderQualificationController.typeRecentPhoto),
                          height: 140.w,
                        )),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(() => ImageUploadCard(
                          title: '健康证',
                          imageUrl: controller.healthCert,
                          onTap: () => controller.pickImage(
                              ProviderQualificationController.typeHealthCert),
                          height: 140.w,
                        )),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => ImageUploadCard(
                          title: '从业证明（选填）',
                          imageUrl: controller.qualificationCert,
                          onTap: () => controller.pickImage(
                              ProviderQualificationController
                                  .typeQualificationCert),
                          height: 140.w,
                        )),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(() => ImageUploadCard(
                          title: '无犯罪记录证明',
                          imageUrl: controller.noCriminalRecord,
                          onTap: () => controller.pickImage(
                              ProviderQualificationController
                                  .typeNoCriminalRecord),
                          height: 140.w,
                        )),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => ImageUploadCard(
                          title: '身份证正面',
                          imageUrl: controller.idCardFront,
                          onTap: () => controller.pickImage(
                              ProviderQualificationController.typeIdCardFront),
                          height: 140.w,
                        )),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(() => ImageUploadCard(
                          title: '身份证反面',
                          imageUrl: controller.idCardBack,
                          onTap: () => controller.pickImage(
                              ProviderQualificationController.typeIdCardBack),
                          height: 140.w,
                        )),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Obx(() => ImageUploadCard(
                    title: '证书（选填）',
                    imageUrl: controller.otherCert,
                    onTap: () => controller.pickImage(
                        ProviderQualificationController.typeOtherCert),
                  )),
              SizedBox(height: 16.h),
              Obx(() => CertificateLevelSelector(
                    selectedLevel: controller.certificateLevel,
                    onLevelChanged: (value) {
                      controller.updateCertificateLevel(value);
                    },
                  )),
              SizedBox(height: 24.h),
              Obx(() => Row(
                    children: [
                      Checkbox(
                        value: controller.agreedToTerms,
                        onChanged: (value) {
                          controller.toggleAgreedToTerms();
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            controller.toggleAgreedToTerms();
                          },
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '我已阅读并同意',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                TextSpan(
                                  text: '《平台入驻协议》',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Theme.of(context).primaryColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
              SizedBox(height: 32.h),
              Obx(() => PrimaryButton(
                    text: controller.isEditMode ? '更新审核' : '提交审核',
                    isLoading: controller.isUploading,
                    onPressed: controller.submitQualifications,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建章节标题
  ///
  /// [title] 标题文本
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
