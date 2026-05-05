import 'dart:io';
import 'package:door_to_door_service/core/services/image_upload_service.dart';
import 'package:door_to_door_service/core/utils/log_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/toast_util.dart';
import '../../data/repositories/user_repository.dart';

/// 实名认证控制器
class RealNameAuthController extends GetxController {
  final String _tag = 'RealNameAuthController';
  final UserRepository _userRepository = UserRepository();
  final ImagePicker _imagePicker = ImagePicker();
  final ImageUploadService _imageUploadService = ImageUploadService();

  /// 是否正在提交实名认证
  final RxBool _isSubmitting = false.obs;

  /// 是否已存在实名认证信息
  final RxBool _hasRealNameAuth = false.obs;

  /// 真实姓名
  final RxString _realName = ''.obs;

  /// 身份证号
  final RxString _idCardNumber = ''.obs;
  final RxString _idCardFrontImageUrl = ''.obs;
  final RxString _idCardBackImageUrl = ''.obs;
  final RxBool _isUploadingIdCardImage = false.obs;

  /// 是否正在提交实名认证
  bool get isSubmitting => _isSubmitting.value;
  bool get hasRealNameAuth => _hasRealNameAuth.value;

  /// 真实姓名
  String get realName => _realName.value;
  RxString get realNameObs => _realName;

  /// 身份证号
  String get idCardNumber => _idCardNumber.value;
  RxString get idCardNumberObs => _idCardNumber;
  String get idCardFrontImageUrl => _idCardFrontImageUrl.value;
  String get idCardBackImageUrl => _idCardBackImageUrl.value;
  bool get isUploadingIdCardImage => _isUploadingIdCardImage.value;

  @override
  void onInit() {
    super.onInit();
    _loadRealNameAuthInfo();
  }

  /// 加载实名认证信息
  Future<void> _loadRealNameAuthInfo() async {
    try {
      final authInfo = await _userRepository.getRealNameAuth();
      
      // 检查是否有实名认证信息
      _hasRealNameAuth.value = authInfo.realName != null && 
                               authInfo.idCardNumber != null &&
                               authInfo.realName!.isNotEmpty && 
                               authInfo.idCardNumber!.isNotEmpty;
      
      if (authInfo.realName != null) {
        _realName.value = authInfo.realName!;
      }
      if (authInfo.idCardNumber != null) {
        _idCardNumber.value = authInfo.idCardNumber!;
      }
      if (authInfo.idCardFrontImageUrl != null) {
        _idCardFrontImageUrl.value = authInfo.idCardFrontImageUrl!;
      }
      if (authInfo.idCardBackImageUrl != null) {
        _idCardBackImageUrl.value = authInfo.idCardBackImageUrl!;
      }
    } catch (e) {
      LogUtil.e('加载实名认证信息失败: $e', tag: _tag);
      // 不显示错误提示，因为用户可能尚未进行实名认证
    }
  }

  /// 更新真实姓名
  /// [value] 用户输入的姓名
  void updateRealName(String value) {
    _realName.value = value;
  }

  /// 更新身份证号
  /// [value] 用户输入的身份证号
  void updateIdCardNumber(String value) {
    _idCardNumber.value = value;
  }

  /// 选择并上传身份证图片
  /// [isFront] true-正面，false-反面
  Future<void> selectAndUploadIdCardImage({required bool isFront}) async {
    if (_isUploadingIdCardImage.value) return;
    try {
      final source = await Get.dialog<ImageSource>(
        AlertDialog(
          title: Text(isFront ? '上传身份证正面' : '上传身份证反面'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
      if (source == null) return;

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1400,
        maxHeight: 1000,
      );
      if (pickedFile == null) return;

      await _uploadIdCardImage(File(pickedFile.path), isFront: isFront);
    } catch (e) {
      LogUtil.e('选择身份证图片失败: $e', tag: _tag);
      ToastUtil.showError('选择身份证图片失败: $e');
    }
  }

  /// 提交实名认证
  Future<void> submitRealNameAuth() async {
    final realName = _realName.value.trim();
    final idCardNumber = _idCardNumber.value.trim().toUpperCase();
    final frontImageUrl = _idCardFrontImageUrl.value;
    final backImageUrl = _idCardBackImageUrl.value;

    if (realName.isEmpty) {
      ToastUtil.showError('请输入真实姓名');
      return;
    }

    if (realName.length < 2) {
      ToastUtil.showError('真实姓名至少需要2个字符');
      return;
    }

    if (!_isValidIdCard(idCardNumber)) {
      ToastUtil.showError('请输入正确的身份证号');
      return;
    }

    if (frontImageUrl.isEmpty) {
      ToastUtil.showError('请上传身份证正面照片');
      return;
    }

    if (backImageUrl.isEmpty) {
      ToastUtil.showError('请上传身份证反面照片');
      return;
    }

    _isSubmitting.value = true;
    try {
      if (_hasRealNameAuth.value) {
        // 已存在实名认证信息，执行更新操作
        await _userRepository.updateRealNameAuth(
          realName: realName,
          idCardNumber: idCardNumber,
          idCardFrontImageUrl: frontImageUrl,
          idCardBackImageUrl: backImageUrl,
        );
        ToastUtil.showSuccess('实名认证更新成功');
      } else {
        // 不存在实名认证信息，执行创建操作
        await _userRepository.createRealNameAuth(
          realName: realName,
          idCardNumber: idCardNumber,
          idCardFrontImageUrl: frontImageUrl,
          idCardBackImageUrl: backImageUrl,
        );
        ToastUtil.showSuccess('实名认证提交成功');
      }
      Get.back(result: true);
    } catch (e) {
      ToastUtil.showError('实名认证提交失败: $e');
    } finally {
      _isSubmitting.value = false;
    }
  }

  /// 验证身份证号格式
  /// [idCardNumber] 身份证号码
  bool _isValidIdCard(String idCardNumber) {
    final pattern = RegExp(r'^\d{17}[\dX]$');
    return pattern.hasMatch(idCardNumber);
  }

  /// 上传身份证图片
  /// [imageFile] 待上传图片文件
  /// [isFront] true-正面，false-反面
  Future<void> _uploadIdCardImage(File imageFile,
      {required bool isFront}) async {
    _isUploadingIdCardImage.value = true;
    try {
      // 上传图片到服务器，获取图片URL
      final imageUrl = await _imageUploadService.uploadImage(imageFile);

      // 只更新本地显示的URL，不保存到服务器
      final normalizedUploadedUrl = _normalizeImageUrl(imageUrl);

      if (isFront) {
        _idCardFrontImageUrl.value = normalizedUploadedUrl;
      } else {
        _idCardBackImageUrl.value = normalizedUploadedUrl;
      }

      ToastUtil.showSuccess(isFront ? '身份证正面上传成功' : '身份证反面上传成功');
    } catch (e) {
      LogUtil.e('上传身份证图片失败: $e', tag: _tag);
      ToastUtil.showError('上传身份证图片失败: $e');
    } finally {
      _isUploadingIdCardImage.value = false;
    }
  }

  /// 规范化图片地址
  /// [url] 原始图片地址
  String _normalizeImageUrl(String? url) {
    final value = (url ?? '').trim();
    if (value.isEmpty) return '';
    if (value.toLowerCase() == 'null' || value.toLowerCase() == 'undefined') {
      return '';
    }
    return value;
  }
}
