
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:door_to_door_service/core/utils/screen_adapter.dart';
import 'package:door_to_door_service/presentation/controllers/address_controller.dart';
import 'package:door_to_door_service/core/models/address_model.dart';
import 'package:uuid/uuid.dart';

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

  // 是否是编辑模式
  bool get _isEditMode => Get.arguments != null && 
                         Get.arguments is Map && 
                         (Get.arguments as Map)['address'] != null;

  // 编辑的地址
  AddressModel? get _editingAddress => _isEditMode 
      ? (Get.arguments as Map)['address'] as AddressModel 
      : null;

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
        id: _isEditMode ? _editingAddress!.id : const Uuid().v4(),
        name: '$_province$_city$_district${_detailAddressController.text}',
        shortName: _detailAddressController.text,
        province: _province,
        city: _city,
        district: _district,
        street: _detailAddressController.text,
        latitude: 0.0, // TODO: 从地图获取
        longitude: 0.0, // TODO: 从地图获取
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
        Get.back(result: true);
        Get.snackbar(
          '成功',
          _isEditMode ? '地址已更新' : '地址已添加',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (mounted) {
        Get.snackbar(
          '失败',
          _isEditMode ? '更新地址失败' : '添加地址失败',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          '错误',
          '保存地址时发生错误',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  /// 从地图选择地址
  Future<void> _selectFromMap() async {
    final result = await Get.toNamed('/map/select');

    if (result != null && result is AddressModel) {
      setState(() {
        _detailAddressController.text = result.street;
        _province = result.province;
        _city = result.city;
        _district = result.district;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? '编辑地址' : '新增地址',
          style: TextStyle(fontSize: 18.sp),
        ),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveAddress,
            child: Text(
              '保存',
              style: TextStyle(
                fontSize: 15.sp,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // 收货人
            _buildFormField(
              label: '收货人',
              controller: _contactNameController,
              hintText: '请输入收货人姓名',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入收货人姓名';
                }
                return null;
              },
            ),

            SizedBox(height: 16.h),

            // 联系电话
            _buildFormField(
              label: '联系电话',
              controller: _contactPhoneController,
              hintText: '请输入联系电话',
              keyboardType: TextInputType.phone,
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

            SizedBox(height: 16.h),

            // 所在地区
            _buildRegionSelector(),

            SizedBox(height: 16.h),

            // 详细地址
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '详细地址',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
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
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _detailAddressController,
                        decoration: InputDecoration(
                          hintText: '请输入详细地址',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[400],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                        ),
                        style: TextStyle(fontSize: 14.sp),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入详细地址';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton.icon(
                      onPressed: _selectFromMap,
                      icon: Icon(Icons.map, size: 18.sp),
                      label: Text(
                        '地图选点',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // 设为默认地址
            SwitchListTile(
              title: Text(
                '设为默认地址',
                style: TextStyle(fontSize: 15.sp),
              ),
              subtitle: Text(
                '下单时将优先使用此地址',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                ),
              ),
              value: _isDefault,
              onChanged: (value) {
                setState(() {
                  _isDefault = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建表单字段
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
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
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[400],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
          ),
          style: TextStyle(fontSize: 14.sp),
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }

  /// 构建地区选择器
  Widget _buildRegionSelector() {
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
            // TODO: 实现省市区选择器
            Get.snackbar(
              '提示',
              '省市区选择器功能开发中',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8.r),
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
                  color: Colors.grey[400],
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
