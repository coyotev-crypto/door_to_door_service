import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../controllers/post_create_controller.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/primary_input_field.dart';

/// 发布帖子页面
class PostCreatePage extends GetView<PostCreateController> {
  const PostCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('发布帖子',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 标题
              PrimaryInputField(
                label: '标题',
                hintText: '请输入标题（最多50字）',
                controller: controller.titleController,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '请输入标题' : null,
              ),
              SizedBox(height: 16.h),
              // 正文
              _buildSectionTitle('正文'),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: TextField(
                  controller: controller.contentController,
                  maxLines: 10,
                  maxLength: PostCreateController.maxContentLength,
                  onChanged: (_) => controller.updateCharCount(),
                  decoration: InputDecoration(
                    hintText: '请输入正文...（至少10字）',
                    hintStyle: TextStyle(
                        fontSize: 14.sp, color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12.w),
                    counterText: '',
                  ),
                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Obx(() => Text(
                      '${controller.charCount.value}/${PostCreateController.maxContentLength}',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                    )),
              ),
              SizedBox(height: 24.h),
              // 图片
              _buildSectionTitle('图片（最多9张）'),
              SizedBox(height: 8.h),
              Obx(() => Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      ...controller.images.asMap().entries.map((e) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.file(
                                File(e.value.path),
                                width: 80.w,
                                height: 80.w,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => controller.removeImage(e.key),
                                child: Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.close,
                                      size: 14.sp, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      if (controller.images.length <
                          PostCreateController.maxImages)
                        GestureDetector(
                          onTap: () => controller.pickImages(),
                          child: Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                  color: Colors.grey[300]!, width: 0.5),
                            ),
                            child: Center(
                              child: Icon(Icons.add_rounded,
                                  size: 28.sp, color: Colors.grey[400]),
                            ),
                          ),
                        ),
                    ],
                  )),
              SizedBox(height: 40.h),
              // 提交
              Obx(() => PrimaryButton(
                    text: '发布',
                    isLoading: controller.isSubmitting.value,
                    onPressed: controller.submit,
                  )),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(title,
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87)),
    );
  }
}
