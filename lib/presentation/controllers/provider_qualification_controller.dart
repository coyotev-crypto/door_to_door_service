import 'dart:io';
import 'package:door_to_door_service/core/services/image_upload_service.dart';
import 'package:door_to_door_service/core/utils/toast_util.dart';
import 'package:door_to_door_service/data/models/address_model.dart';
import 'package:door_to_door_service/data/models/provider_qualification_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/log_util.dart';
import '../../data/repositories/provider_repository.dart';

/// 服务商资质材料控制器
class ProviderQualificationController extends GetxController {
  // 图片类型常量
  static const String typeRecentPhoto = 'recentPhoto';
  static const String typeHealthCert = 'healthCert';
  static const String typeQualificationCert = 'qualificationCert';
  static const String typeOtherCert = 'otherCert';
  static const String typeIdCardFront = 'idCardFront';
  static const String typeIdCardBack = 'idCardBack';
  static const String typeNoCriminalRecord = 'noCriminalRecord';

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
  final RxBool _isLoading = false.obs;
  final Rxn<ProviderQualificationModel> _qualificationData =
      Rxn<ProviderQualificationModel>();

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

  /// 是否正在加载
  bool get isLoading => _isLoading.value;

  /// 资质记录ID，非空表示编辑模式
  int? get qualificationId => _qualificationData.value?.id;

  /// 是否为编辑模式
  bool get isEditMode => qualificationId != null;

  /// 资质认证数据
  ProviderQualificationModel? get qualificationData => _qualificationData.value;

  @override
  void onInit() {
    super.onInit();
    fetchMyQualification();
  }

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
        case typeRecentPhoto:
          _recentPhoto.value = imageUrl;
          break;
        case typeHealthCert:
          _healthCert.value = imageUrl;
          break;
        case typeQualificationCert:
          _qualificationCert.value = imageUrl;
          break;
        case typeOtherCert:
          _otherCert.value = imageUrl;
          break;
        case typeIdCardFront:
          _idCardFront.value = imageUrl;
          break;
        case typeIdCardBack:
          _idCardBack.value = imageUrl;
          break;
        case typeNoCriminalRecord:
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
    if (!validateForm()) return;

    _isUploading.value = true;
    try {
      if (isEditMode) {
        await _updateQualifications();
      } else {
        await _createQualifications();
      }
    } finally {
      _isUploading.value = false;
    }
  }

  /// 创建资质材料
  Future<void> _createQualifications() async {
    try {
      final response = await _providerRepository.submitQualification(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        age: int.parse(ageController.text.trim()),
        gender: _gender.value,
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
      );
      if (response.isSuccess) {
        Get.back();
        ToastUtil.showSuccess('资质材料已提交，请等待审核');
      }
    } catch (e) {
      LogUtil.e('提交资质材料失败: $e', tag: _tag);
      ToastUtil.showError('$e');
    }
  }

  /// 更新资质材料
  Future<void> _updateQualifications() async {
    try {
      final response = await _providerRepository.updateQualification(
        id: qualificationId!,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        age: int.parse(ageController.text.trim()),
        gender: _gender.value,
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
      );
      if (response.isSuccess) {
        Get.back();
        ToastUtil.showSuccess('资质材料已更新，请等待审核');
      }
    } catch (e) {
      LogUtil.e('更新资质材料失败: $e', tag: _tag);
      ToastUtil.showError('$e');
    }
  }

  /// 获取当前用户资质认证数据
  ///
  /// 从服务器获取当前用户的资质认证信息，并更新UI状态
  Future<void> fetchMyQualification() async {
    _isLoading.value = true;
    try {
      final response = await _providerRepository.getMyQualification();
      if (response.isSuccess && response.data != null) {
        _qualificationData.value = response.data;
        // 更新表单数据
        _updateFormData(response.data!);
      }
    } catch (e) {
      LogUtil.e('获取资质认证数据失败: $e', tag: _tag);
      ToastUtil.showError('获取资质认证数据失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// 更新表单数据
  ///
  /// [data] 资质认证数据
  void _updateFormData(ProviderQualificationModel data) {
    nameController.text = data.name ?? '';
    phoneController.text = data.phone ?? '';
    ageController.text = data.age?.toString() ?? '';
    emergencyContactController.text = data.emergencyContact ?? '';
    emergencyPhoneController.text = data.emergencyPhone ?? '';

    if (data.gender != null &&
        (data.gender == 'male' || data.gender == 'female')) {
      _gender.value = data.gender!;
    }

    if (data.certificateLevel != null) {
      _certificateLevel.value = data.certificateLevel;
    }

    // 更新图片URL
    if (data.recentPhoto != null) {
      _recentPhoto.value = data.recentPhoto!;
    }
    if (data.healthCert != null) {
      _healthCert.value = data.healthCert!;
    }
    if (data.qualificationCert != null) {
      _qualificationCert.value = data.qualificationCert!;
    }
    if (data.otherCert != null) {
      _otherCert.value = data.otherCert!;
    }
    if (data.idCardFront != null) {
      _idCardFront.value = data.idCardFront!;
    }
    if (data.idCardBack != null) {
      _idCardBack.value = data.idCardBack!;
    }
    if (data.noCriminalRecord != null) {
      _noCriminalRecord.value = data.noCriminalRecord!;
    }
    _agreedToTerms.value = true;
  }
}
