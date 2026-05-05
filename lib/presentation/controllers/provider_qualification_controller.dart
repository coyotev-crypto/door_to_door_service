import 'dart:io';
import 'package:door_to_door_service/core/services/image_upload_service.dart';
import 'package:door_to_door_service/core/utils/toast_util.dart';
import 'package:door_to_door_service/data/models/address_model.dart';
import 'package:door_to_door_service/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/log_util.dart';
import '../../data/repositories/provider_repository.dart';

/// 服务商资质材料控制器
class ProviderQualificationController extends GetxController {
  final String _tag = 'ProviderQualificationController';
  final ImagePicker _imagePicker = ImagePicker();
  final ImageUploadService _imageUploadService = ImageUploadService();
  final ProviderRepository _providerRepository = ProviderRepository();

  // 表单控制器
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController serviceRangeController = TextEditingController();
  final TextEditingController emergencyContactController =
      TextEditingController();
  final TextEditingController emergencyPhoneController =
      TextEditingController();

  // 响应式状态
  final RxString _gender = 'male'.obs;
  final RxnString _certificateLevel = RxnString();
  final Rx<AddressModel?> _selectedCity = Rx<AddressModel?>(null);
  final RxBool _isUploading = false.obs;
  final RxBool _agreedToTerms = false.obs;

  // 资质材料图片URL
  final RxString _recentPhoto = ''.obs;
  final RxString _healthCert = ''.obs;
  final RxString _qualificationCert = ''.obs;
  final RxString _otherCert = ''.obs;
  final RxString _idCardFront = ''.obs;
  final RxString _idCardBack = ''.obs;
  final RxString _noCriminalRecord = ''.obs;

  // 表单校验Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// 性别
  String get gender => _gender.value;

  /// 证书等级
  String? get certificateLevel => _certificateLevel.value;

  /// 选中的合作城市地址
  AddressModel? get selectedCity => _selectedCity.value;

  /// 是否正在上传
  bool get isUploading => _isUploading.value;

  /// 是否同意平台入驻协议
  bool get agreedToTerms => _agreedToTerms.value;

  /// 本人近期照
  String get recentPhoto => _recentPhoto.value;

  /// 健康证
  String get healthCert => _healthCert.value;

  /// 从业证明
  String get qualificationCert => _qualificationCert.value;

  /// 证书
  String get otherCert => _otherCert.value;

  /// 身份证正面
  String get idCardFront => _idCardFront.value;

  /// 身份证反面
  String get idCardBack => _idCardBack.value;

  /// 无犯罪记录证明
  String get noCriminalRecord => _noCriminalRecord.value;

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    ageController.dispose();
    cityController.dispose();
    serviceRangeController.dispose();
    emergencyContactController.dispose();
    emergencyPhoneController.dispose();
    super.onClose();
  }

  /// 更新性别
  ///
  /// [value] 性别值，可选值：'male'、'female'
  void updateGender(String? value) {
    if (value != null && (value == 'male' || value == 'female')) {
      _gender.value = value;
    }
  }

  /// 更新证书等级
  ///
  /// [value] 证书等级值，可选值：'初级'、'中级'、'高级'、'专家'
  void updateCertificateLevel(String? value) {
    if (value != null) {
      _certificateLevel.value = value;
    }
  }

  /// 更新协议同意状态
  void toggleAgreedToTerms() {
    _agreedToTerms.value = !_agreedToTerms.value;
  }

  /// 选择合作城市
  Future<void> selectCity() async {
    final result = await Get.toNamed(RouteNames.mapSelect);
    if (result != null && result is AddressModel) {
      _selectedCity.value = result;
      cityController.text = result.name;
    }
  }

  /// 选择图片
  Future<void> pickImage(String type) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile == null) return;

      // 上传图片
      final imageUrl =
          await _imageUploadService.uploadImage(File(pickedFile.path));

      // 更新对应的图片URL
      switch (type) {
        case 'recentPhoto':
          _recentPhoto.value = imageUrl;
          break;
        case 'healthCert':
          _healthCert.value = imageUrl;
          break;
        case 'qualificationCert':
          _qualificationCert.value = imageUrl;
          break;
        case 'otherCert':
          _otherCert.value = imageUrl;
          break;
        case 'idCardFront':
          _idCardFront.value = imageUrl;
          break;
        case 'idCardBack':
          _idCardBack.value = imageUrl;
          break;
        case 'noCriminalRecord':
          _noCriminalRecord.value = imageUrl;
          break;
      }
    } catch (e) {
      LogUtil.e('选择图片失败: $e', tag: _tag);
      ToastUtil.showError('选择图片失败: $e');
    }
  }

  /// 验证表单
  bool validateForm() {
    // 验证表单字段
    if (!formKey.currentState!.validate()) {
      return false;
    }

    // 验证性别
    if (_gender.value.isEmpty) {
      ToastUtil.showError('请选择性别');
      return false;
    }

    // 验证合作城市
    if (_selectedCity.value == null) {
      ToastUtil.showError('请选择意向合作城市');
      return false;
    }

    // 验证资质材料
    if (_recentPhoto.value.isEmpty) {
      ToastUtil.showError('请上传本人近期照');
      return false;
    }

    if (_healthCert.value.isEmpty) {
      ToastUtil.showError('请上传健康证');
      return false;
    }

    // 从业证明为可选字段，不再强制验证

    if (_idCardFront.value.isEmpty) {
      ToastUtil.showError('请上传身份证正面照片');
      return false;
    }

    if (_idCardBack.value.isEmpty) {
      ToastUtil.showError('请上传身份证反面照片');
      return false;
    }

    if (_noCriminalRecord.value.isEmpty) {
      ToastUtil.showError('请上传无犯罪记录证明');
      return false;
    }

    // 验证协议
    if (!_agreedToTerms.value) {
      ToastUtil.showError('请阅读并同意平台入驻协议');
      return false;
    }

    return true;
  }

  /// 提交资质材料
  Future<void> submitQualifications() async {
    // 验证表单
    if (!validateForm()) {
      return;
    }

    _isUploading.value = true;
    try {
      // 调用API提交资质材料
      await _providerRepository.submitQualification(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        age: int.parse(ageController.text.trim()),
        gender: _gender.value,
        cityId: _selectedCity.value?.id ?? 0,
        cityName: _selectedCity.value?.name ?? '',
        serviceRange: double.parse(serviceRangeController.text.trim()),
        emergencyContact: emergencyContactController.text.trim(),
        emergencyPhone: emergencyPhoneController.text.trim(),
        recentPhoto: _recentPhoto.value,
        healthCert: _healthCert.value,
        qualificationCert: _qualificationCert.value,
        otherCert: _otherCert.value,
        idCardFront: _idCardFront.value,
        idCardBack: _idCardBack.value,
        noCriminalRecord: _noCriminalRecord.value,
        certificateLevel: _certificateLevel.value ?? '',
        latitude: _selectedCity.value?.latitude ?? 0.0,
        longitude: _selectedCity.value?.longitude ?? 0.0,
      );

      ToastUtil.showSuccess('资质材料已提交，请等待审核');
      Get.back();
    } catch (e) {
      LogUtil.e('提交资质材料失败: $e', tag: _tag);
      ToastUtil.showError('提交失败: $e');
    } finally {
      _isUploading.value = false;
    }
  }
}
