import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../controllers/real_name_auth_controller.dart';

/// 实名认证页面
class RealNameAuthScreen extends StatefulWidget {
  const RealNameAuthScreen({super.key});

  @override
  State<RealNameAuthScreen> createState() => _RealNameAuthScreenState();
}

class _RealNameAuthScreenState extends State<RealNameAuthScreen> {
  final RealNameAuthController _controller = Get.find<RealNameAuthController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _realNameController;
  late TextEditingController _idCardController;

  @override
  void initState() {
    super.initState();
    _realNameController = TextEditingController(text: _controller.realName);
    _idCardController = TextEditingController(text: _controller.idCardNumber);

    // 监听控制器中的数据变化
    ever(_controller.realNameObs, (String value) {
      if (_realNameController.text != value) {
        _realNameController.value = TextEditingValue(text: value);
      }
    });

    ever(_controller.idCardNumberObs, (String value) {
      if (_idCardController.text != value) {
        _idCardController.value = TextEditingValue(text: value);
      }
    });
  }

  @override
  void dispose() {
    _realNameController.dispose();
    _idCardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('实名认证'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppTheme.servicePrimaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    _controller.hasRealNameAuth
                        ? '您已提交实名认证，可更新您的身份信息。'
                        : '请填写真实身份信息，提交后将用于账户安全校验。',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                );
              }),
              SizedBox(height: 20.h),
              _buildFormField(
                controller: _realNameController,
                label: '真实姓名',
                hintText: '请输入真实姓名',
                onChanged: _controller.updateRealName,
                validator: (value) {
                  final input = value?.trim() ?? '';
                  if (input.isEmpty) {
                    return '请输入真实姓名';
                  }
                  if (input.length < 2) {
                    return '真实姓名至少需要2个字符';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              _buildFormField(
                controller: _idCardController,
                label: '身份证号',
                hintText: '请输入18位身份证号',
                textCapitalization: TextCapitalization.characters,
                onChanged: _controller.updateIdCardNumber,
                validator: (value) {
                  final input = (value ?? '').trim().toUpperCase();
                  if (input.isEmpty) {
                    return '请输入身份证号';
                  }
                  if (!RegExp(r'^\d{17}[\dX]$').hasMatch(input)) {
                    return '请输入正确的身份证号';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              Obx(() {
                return _buildUploadSection();
              }),
              SizedBox(height: 28.h),
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _controller.isSubmitting
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _controller.submitRealNameAuth();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.servicePrimaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppTheme.servicePrimaryColor.withOpacity(0.5),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      elevation: 0,
                    ),
                    child: _controller.isSubmitting
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _controller.hasRealNameAuth ? '更新认证' : '提交认证',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建身份证上传区域
  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '身份证照片',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _buildIdCardUploadItem(
                label: '正面',
                imageUrl: _controller.idCardFrontImageUrl,
                onTap: () =>
                    _controller.selectAndUploadIdCardImage(isFront: true),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildIdCardUploadItem(
                label: '反面',
                imageUrl: _controller.idCardBackImageUrl,
                onTap: () =>
                    _controller.selectAndUploadIdCardImage(isFront: false),
              ),
            ),
          ],
        ),
        if (_controller.isUploadingIdCardImage) ...[
          SizedBox(height: 8.h),
          Text(
            '图片上传中，请稍候...',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  /// 构建身份证上传项
  Widget _buildIdCardUploadItem({
    required String label,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    final normalizedImageUrl = _normalizeImageUrl(imageUrl);
    final hasImage = normalizedImageUrl.isNotEmpty;
    return GestureDetector(
      onTap: _controller.isUploadingIdCardImage ? null : onTap,
      child: Container(
        height: 110.h,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: hasImage
                ? AppTheme.servicePrimaryColor.withOpacity(0.6)
                : Colors.grey[300]!,
          ),
          image: hasImage
              ? DecorationImage(
                  image: NetworkImage(normalizedImageUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: hasImage
            ? Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: EdgeInsets.all(6.w),
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '重新上传$label',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: Colors.grey[600],
                    size: 20.sp,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '上传身份证$label',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
      ),
    );
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

  /// 构建表单输入框
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required ValueChanged<String> onChanged,
    required String? Function(String?) validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(
                color: AppTheme.servicePrimaryColor,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 14.h,
            ),
          ),
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
