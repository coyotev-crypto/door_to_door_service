import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../controllers/post_create_controller.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/common_app_bar.dart';
import '../../../core/themes/app_theme.dart';
import '../../widgets/primary_input_field.dart';

/// 发布帖子页面 — 小红书风格
class PostCreatePage extends GetView<PostCreateController> {
  const PostCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: const CommonAppBar(title: '发布笔记'),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 图片选择区 ──
              _buildImageGrid(context),
              SizedBox(height: 20.h),
              // ── 标题 ──
              PrimaryInputField(
                controller: controller.titleController,
                hintText: '添加标题',
                maxLength: PostCreateController.maxTitleLength,
                validator: (v) => (v == null || v.trim().isEmpty) ? '请输入标题' : null,
              ),
              SizedBox(height: 12.h),
              // ── 正文 ──
              PrimaryInputField(
                controller: controller.contentController,
                hintText: '说点什么...',
                maxLines: 8,
                maxLength: PostCreateController.maxContentLength,
                onChanged: (_) => controller.updateCharCount(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Obx(() => Text(
                      '${controller.charCount.value}/${PostCreateController.maxContentLength}',
                      style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted),
                    )),
              ),
              SizedBox(height: 16.h),
              SizedBox(height: 40.h),
              // ── 发布按钮 ──
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

  // ── 图片网格：每行 3 张 1:1 正方形 ──
  Widget _buildImageGrid(BuildContext context) {
    return Obx(() => LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final spacing = 8.w;
            final imageSize = (availableWidth - spacing * 2) / 3;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                ...controller.images.asMap().entries.map((e) {
                  return SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.file(
                            File(e.value.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4.w,
                          right: 4.w,
                          child: GestureDetector(
                            onTap: () => controller.removeImage(e.key),
                            child: Container(
                              width: 22.w,
                              height: 22.w,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close, size: 14.sp, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (controller.images.length < PostCreateController.maxImages)
                  GestureDetector(
                    onTap: () => controller.pickImages(),
                    child: Container(
                      width: imageSize,
                      height: imageSize,
                      decoration: BoxDecoration(
                        color: AppTheme.creamFill,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppTheme.warmBorder, width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 28.sp, color: AppTheme.textMuted),
                          SizedBox(height: 4.h),
                          Text('添加图片', style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ));
  }
}
