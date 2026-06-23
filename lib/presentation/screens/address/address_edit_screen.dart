import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:door_to_door_service/core/utils/screen_adapter.dart';
import 'package:door_to_door_service/core/utils/toast_util.dart';
import 'package:door_to_door_service/routes/route_names.dart';
import 'package:door_to_door_service/presentation/controllers/address_controller.dart';
import 'package:door_to_door_service/data/models/address_model.dart';
import '../../widgets/common_app_bar.dart';
import '../../../core/themes/app_theme.dart';
import '../../widgets/primary_input_field.dart';

/// 地址编辑页面
///
/// 提供地址添加和编辑功能
class AddressEditScreen extends StatefulWidget {
  const AddressEditScreen({super.key});

  @override
  State<AddressEditScreen> createState() => _AddressEditScreenState();
}

class _AddressEditScreenState extends State<AddressEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _detailAddressController = TextEditingController();

  // 表单数据
  String _province = '北京市';
  String _city = '北京市';
  String _district = '朝阳区';
  bool _isDefault = false;
  double _latitude = 0.0;
  double _longitude = 0.0;

  // 是否是编辑模式
  bool get _isEditMode =>
      Get.arguments != null &&
      Get.arguments is Map &&
      (Get.arguments as Map)['address'] != null;

  // 编辑的地址
  AddressModel? get _editingAddress =>
      _isEditMode ? (Get.arguments as Map)['address'] as AddressModel : null;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  /// 初始化数据
  void _initData() {
    if (_isEditMode && _editingAddress != null) {
      final address = _editingAddress!;
      _contactNameController.text = address.contactName ?? '';
      _contactPhoneController.text = address.contactPhone ?? '';
      _detailAddressController.text = address.street;
      _province = address.province;
      _city = address.city;
      _district = address.district;
      _isDefault = address.isDefault;
      _latitude = address.latitude;
      _longitude = address.longitude;
    }
  }

  /// 保存地址
  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = Get.find<AddressController>();

    try {
      final address = AddressModel(
        id: _isEditMode ? _editingAddress!.id : 0,
        name: '$_province$_city$_district${_detailAddressController.text}',
        shortName: _detailAddressController.text,
        province: _province,
        city: _city,
        district: _district,
        street: _detailAddressController.text,
        latitude: _latitude,
        longitude: _longitude,
        isDefault: _isDefault,
        contactName: _contactNameController.text,
        contactPhone: _contactPhoneController.text,
      );

      bool success;
      if (_isEditMode) {
        success = await controller.updateAddress(address);
      } else {
        success = await controller.addAddress(address);
      }

      if (success && mounted) {
        // 先显示成功提示
        ToastUtil.showSuccess(
          _isEditMode ? '地址已更新' : '地址已添加',
        );
        // 稍微延迟一下，让用户看到提示信息
        await Future.delayed(const Duration(milliseconds: 500));
        // 然后返回上一页
        if (mounted) {
          Get.back(result: true);
        }
      } else if (mounted) {
        ToastUtil.showError(
          _isEditMode ? '更新地址失败' : '添加地址失败',
        );
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showError(
          '保存地址时发生错误',
        );
      }
    }
  }

  /// 从地图选择地址
  Future<void> _selectFromMap() async {
    final result = await Get.toNamed(RouteNames.mapSelect);

    if (result != null && result is AddressModel) {
      setState(() {
        _detailAddressController.text = result.street;
        _province = result.province;
        _city = result.city;
        _district = result.district;
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: CommonAppBar(title: _isEditMode ? '编辑地址' : '新增地址'),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                children: [
                  // 收货人
                  PrimaryInputField(
                    label: '收货人',
                    controller: _contactNameController,
                    hintText: '请输入收货人姓名',
                    maxLength: 20,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入收货人姓名';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 8.h),

                  // 联系电话
                  PrimaryInputField(
                    label: '联系电话',
                    controller: _contactPhoneController,
                    hintText: '请输入联系电话',
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入联系电话';
                      }
                      // 简单的手机号验证
                      if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                        return '请输入有效的手机号';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 8.h),

                  // 所在地区
                  _buildRegionSelector(themeColor),

                  SizedBox(height: 8.h),

                  // 详细地址
                  PrimaryInputField(
                    label: '详细地址',
                    controller: _detailAddressController,
                    hintText: '请输入详细地址',
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入详细地址';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 12.h),

                  // 地图选点
                  Container(
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _selectFromMap,
                        borderRadius: BorderRadius.circular(12.r),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 20.sp,
                                color: themeColor,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '地图选点',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: themeColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 设为默认地址
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.grey[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '设为默认地址',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '下单时将优先使用此地址',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isDefault,
                          onChanged: (value) {
                            setState(() {
                              _isDefault = value;
                            });
                          },
                          activeThumbColor: themeColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 保存按钮
            Padding(
              padding: EdgeInsets.all(24.w),
              child: _buildSaveButton(themeColor),
            ),
          ],
        ),
      ),
    );
  }


  /// 构建地区选择器
  Widget _buildRegionSelector(Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '所在地区',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.red,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () {
            _selectFromMap();
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$_province $_city $_district',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: themeColor,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建保存按钮
  Widget _buildSaveButton(Color themeColor) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColor,
            themeColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _saveAddress,
          borderRadius: BorderRadius.circular(12.r),
          child: Center(
            child: Text(
              '保存',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
