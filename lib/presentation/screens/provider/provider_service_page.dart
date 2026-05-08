import 'package:door_to_door_service/data/models/category_model.dart';
import 'package:door_to_door_service/presentation/controllers/provider_service_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/primary_input_field.dart';

/// 服务商完善服务页面
class ProviderServicePage extends GetView<ProviderServiceController> {
  const ProviderServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          controller.isEditMode ? '编辑服务' : '完善服务',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildForm(context);
      }),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('基本信息'),
            SizedBox(height: 12.h),
            PrimaryInputField(
              label: '服务名称',
              hintText: '请输入服务名称',
              controller: controller.nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入服务名称';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            _buildCategorySelector(context),
            SizedBox(height: 16.h),
            PrimaryInputField(
              label: '服务商名称',
              hintText: '请输入服务商名称',
              controller: controller.providerNameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入服务商名称';
                }
                return null;
              },
            ),
            SizedBox(height: 24.h),
            _buildSectionTitle('服务区域'),
            SizedBox(height: 12.h),
            _buildCitySelector(context),
            SizedBox(height: 16.h),
            PrimaryInputField(
              label: '配送范围（KM）',
              hintText: '请输入配送范围（公里）',
              keyboardType: TextInputType.number,
              controller: controller.deliveryRangeController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入配送范围';
                }
                final range = double.tryParse(value);
                if (range == null || range <= 0) {
                  return '请输入有效的配送范围';
                }
                return null;
              },
            ),
            SizedBox(height: 24.h),
            _buildSectionTitle('价格信息'),
            SizedBox(height: 12.h),
            PrimaryInputField(
              label: '原价',
              hintText: '请输入服务价格',
              keyboardType: TextInputType.number,
              controller: controller.priceController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入服务价格';
                }
                final price = double.tryParse(value);
                if (price == null || price < 0) {
                  return '请输入有效的价格';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            PrimaryInputField(
              label: '交通费/公里（选填）',
              hintText: '请输入每公里交通费',
              keyboardType: TextInputType.number,
              controller: controller.travelFeeController,
            ),
            SizedBox(height: 24.h),
            _buildSectionTitle('服务状态'),
            SizedBox(height: 12.h),
            _buildStatusSelector(context),
            SizedBox(height: 40.h),
            Obx(() => PrimaryButton(
                  text: controller.isEditMode ? '保存修改' : '提交服务',
                  isLoading: controller.isSubmitting,
                  onPressed: controller.submit,
                )),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  /// 构建分类选择器
  Widget _buildCategorySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Text(
            '服务分类',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() {
          if (controller.categories.isEmpty) {
            return _buildDropdownButton(context, null, []);
          }
          return _buildDropdownButton(
            context,
            controller.selectedCategory,
            controller.categories,
          );
        }),
      ],
    );
  }

  /// 构建下拉选择按钮
  Widget _buildDropdownButton(
    BuildContext context,
    CategoryModel? selected,
    List<CategoryModel> items,
  ) {
    return Container(
      width: double.infinity,
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.grey[50],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CategoryModel>(
          value: selected,
          isExpanded: true,
          hint: Text(
            '请选择服务分类',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20.sp),
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
          ),
          items: items.map((category) {
            return DropdownMenuItem<CategoryModel>(
              value: category,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: (value) => controller.updateCategory(value),
        ),
      ),
    );
  }

  /// 构建状态选择器
  Widget _buildStatusSelector(BuildContext context) {
    return Obx(() {
      return Container(
        width: double.infinity,
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8.r),
          color: Colors.grey[50],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: controller.status,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20.sp),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
            items: const [
              DropdownMenuItem(value: 1, child: Text('上架')),
              DropdownMenuItem(value: 0, child: Text('下架')),
            ],
            onChanged: (value) {
              if (value != null) {
                controller.updateStatus(value);
              }
            },
          ),
        ),
      );
    });
  }

  /// 构建意向城市选择器
  Widget _buildCitySelector(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.selectCity(),
      child: Container(
        width: double.infinity,
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8.r),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            Icon(Icons.location_on_rounded,
                color: Theme.of(context).primaryColor, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Obx(() {
                final city = controller.selectedCity;
                if (city != null && city.name.isNotEmpty) {
                  return Text(
                    city.name,
                    style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                }
                return Text(
                  '请选择意向合作城市',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                );
              }),
            ),
            Icon(Icons.chevron_right_rounded, size: 20.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// 构建章节标题
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
