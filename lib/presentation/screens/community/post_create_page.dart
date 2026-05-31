import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../controllers/post_create_controller.dart';
import '../../widgets/primary_button.dart';

/// 发布帖子页面 — 小红书风格
class PostCreatePage extends GetView<PostCreateController> {
  const PostCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      appBar: AppBar(
        title: Text('发布笔记',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0, scrolledUnderElevation: 0.5,
      ),
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
              _buildTitleInput(context),
              SizedBox(height: 12.h),
              // ── 正文 ──
              _buildContentInput(context),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = (screenWidth - 32.w - 16.w) / 3;

    return Obx(() => Wrap(
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
                      width: imageSize,
                      height: imageSize,
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
                        child:
                            Icon(Icons.close, size: 14.sp, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }),
            if (controller.images.length < PostCreateController.maxImages)
              GestureDetector(
                onTap: () => controller.pickImages(),
                child: Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F7F4),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Icon(Icons.add_rounded,
                        size: 32.sp, color: Colors.grey[300]),
                  ),
                ),
              ),
          ],
        ));
  }

  // ── 标题输入：浅灰圆角背景 ──
  Widget _buildTitleInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7F4),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextFormField(
        controller: controller.titleController,
        maxLength: PostCreateController.maxTitleLength,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: '添加标题',
          hintStyle: TextStyle(fontSize: 16.sp, color: Colors.grey[400]),
          border: InputBorder.none,
          isCollapsed: true,
          counterText: '',
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? '请输入标题' : null,
      ),
    );
  }

  // ── 正文输入：浅灰圆角背景 + 字数统计 ──
  Widget _buildContentInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7F4),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: controller.contentController,
            maxLines: 8,
            maxLength: PostCreateController.maxContentLength,
            onChanged: (_) => controller.updateCharCount(),
            style:
                TextStyle(fontSize: 15.sp, color: Colors.black87, height: 1.6),
            decoration: InputDecoration(
              hintText: '说点什么...',
              hintStyle: TextStyle(fontSize: 15.sp, color: Colors.grey[400]),
              border: InputBorder.none,
              isCollapsed: true,
              counterText: '',
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Obx(() => Text(
                  '${controller.charCount.value}/${PostCreateController.maxContentLength}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
                )),
          ),
        ],
      ),
    );
  }
}
