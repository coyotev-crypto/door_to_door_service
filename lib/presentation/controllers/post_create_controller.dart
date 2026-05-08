import 'dart:io';
import 'package:door_to_door_service/core/services/image_upload_service.dart';
import 'package:door_to_door_service/core/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/log_util.dart';
import '../../data/repositories/post_repository.dart';

/// 发布帖子控制器
class PostCreateController extends GetxController {
  final String _tag = 'PostCreateController';
  final PostRepository _repository = PostRepository();
  final ImagePicker _imagePicker = ImagePicker();
  final ImageUploadService _imageUploadService = ImageUploadService();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxList<File> images = <File>[].obs;
  final RxList<String> tags = <String>[].obs;
  final RxBool isSubmitting = false.obs;
  final RxInt charCount = 0.obs;

  static const int maxImages = 9;
  static const int maxTitleLength = 50;
  static const int maxContentLength = 5000;
  static const int minContentLength = 10;

  String? get titleError {
    final text = titleController.text.trim();
    if (text.isEmpty) return null; // will be validated on submit
    if (text.length > maxTitleLength) return '标题不能超过$maxTitleLength字';
    return null;
  }

  String? get contentError {
    final text = contentController.text.trim();
    if (text.isEmpty) return null;
    if (text.length > maxContentLength) return '正文不能超过$maxContentLength字';
    return null;
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }

  /// 选择图片
  Future<void> pickImages() async {
    if (images.length >= maxImages) {
      ToastUtil.showError('最多上传$maxImages张图片');
      return;
    }
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
      );
      if (pickedFiles.isEmpty) return;
      for (final file in pickedFiles) {
        if (images.length >= maxImages) break;
        images.add(File(file.path));
      }
    } catch (e) {
      LogUtil.e('选择图片失败: $e', tag: _tag);
    }
  }

  void removeImage(int index) {
    images.removeAt(index);
  }

  void addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty) return;
    if (tags.contains(trimmed)) {
      ToastUtil.showError('标签已存在');
      return;
    }
    if (tags.length >= 5) {
      ToastUtil.showError('最多添加5个标签');
      return;
    }
    tags.add(trimmed);
  }

  void removeTag(String tag) {
    tags.remove(tag);
  }

  /// 提交发布
  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty) {
      ToastUtil.showError('请输入标题');
      return;
    }
    if (title.length > maxTitleLength) {
      ToastUtil.showError('标题不能超过$maxTitleLength字');
      return;
    }
    if (content.length < minContentLength) {
      ToastUtil.showError('正文至少$minContentLength字');
      return;
    }
    if (tags.isEmpty) {
      ToastUtil.showError('请至少添加一个标签');
      return;
    }

    isSubmitting.value = true;
    try {
      final uploadedUrls = <String>[];
      for (final image in images) {
        final url = await _imageUploadService.uploadImage(image);
        uploadedUrls.add(url);
      }

      final response = await _repository.createPost(
        title: title,
        content: content,
        images: uploadedUrls,
        tags: tags.toList(),
      );

      if (response.isSuccess) {
        ToastUtil.showSuccess('发布成功');
        Get.back(result: true);
      }
    } catch (e) {
      LogUtil.e('发布失败: $e', tag: _tag);
      ToastUtil.showError('$e');
    } finally {
      isSubmitting.value = false;
    }
  }

  void updateCharCount() {
    charCount.value = contentController.text.length;
  }
}
