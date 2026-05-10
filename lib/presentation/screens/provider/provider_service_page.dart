import 'package:door_to_door_service/data/models/category_model.dart';
import 'package:door_to_door_service/presentation/controllers/provider_service_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../widgets/primary_button.dart';

/// 服务商完善服务页面
class ProviderServicePage extends GetView<ProviderServiceController> {
  const ProviderServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          controller.isEditMode ? '编辑服务' : '完善服务',
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            _buildCard([
              _buildCardTitle(Icons.info_outline_rounded, '基本信息'),
              SizedBox(height: 16.h),
              _buildField('服务名称', '请输入服务名称', controller.nameController,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '请输入服务名称' : null),
              SizedBox(height: 14.h),
              _buildCategorySelector(context),
              SizedBox(height: 14.h),
              _buildField(
                  '服务商名称', '请输入服务商名称', controller.providerNameController,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '请输入服务商名称' : null),
            ]),
            SizedBox(height: 12.h),
            _buildCard([
              _buildCardTitle(Icons.location_on_outlined, '服务区域'),
              SizedBox(height: 16.h),
              _buildCitySelector(context),
              SizedBox(height: 14.h),
              _buildField(
                  '配送范围（KM）', '请输入配送范围（公里）', controller.deliveryRangeController,
                  keyboardType: TextInputType.number, validator: (v) {
                if (v == null || v.trim().isEmpty) return '请输入配送范围';
                final range = double.tryParse(v);
                if (range == null || range <= 0) return '请输入有效的配送范围';
                return null;
              }),
            ]),
            SizedBox(height: 12.h),
            _buildCard([
              _buildCardTitle(Icons.access_time_rounded, '可服务时间段'),
              SizedBox(height: 12.h),
              _buildTimeSlotSection(context),
            ]),
            SizedBox(height: 12.h),
            _buildCard([
              _buildCardTitle(Icons.attach_money_rounded, '价格信息'),
              SizedBox(height: 16.h),
              _buildField('原价', '请输入服务价格', controller.priceController,
                  keyboardType: TextInputType.number, validator: (v) {
                if (v == null || v.trim().isEmpty) return '请输入服务价格';
                final price = double.tryParse(v);
                if (price == null || price < 0) return '请输入有效的价格';
                return null;
              }),
              SizedBox(height: 14.h),
              _buildField(
                  '交通费/公里（选填）', '请输入每公里交通费', controller.travelFeeController,
                  keyboardType: TextInputType.number, required: false),
            ]),
            SizedBox(height: 12.h),
            _buildCard([
              _buildCardTitle(Icons.toggle_on_rounded, '服务状态'),
              SizedBox(height: 12.h),
              _buildStatusSelector(context),
            ]),
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

  // ── 卡片容器 ──
  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildCardTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: Colors.black54),
        SizedBox(width: 6.w),
        Text(title,
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
      ],
    );
  }

  // ── 输入字段 ──
  Widget _buildField(String label, String hint, TextEditingController ctrl,
      {TextInputType? keyboardType,
      bool required = true,
      FormFieldValidator<String>? validator}) {
    final baseValidator = required
        ? (v) {
            if (v == null || v.trim().isEmpty) return '请输入$label';
            return null;
          }
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87)),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextFormField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 15.sp, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 15.sp, color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              isCollapsed: true,
            ),
            validator: validator ?? baseValidator,
          ),
        ),
      ],
    );
  }

  // ── 分类选择 ──
  Widget _buildCategorySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('服务分类',
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87)),
        SizedBox(height: 6.h),
        Obx(() {
          final items = controller.categories;
          return Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CategoryModel>(
                value: controller.selectedCategory,
                isExpanded: true,
                hint: Text('请选择服务分类',
                    style: TextStyle(fontSize: 15.sp, color: Colors.grey[400])),
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 22.sp, color: Colors.grey[500]),
                style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                items: items
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => controller.updateCategory(v),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── 城市选择 ──
  Widget _buildCitySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('意向合作城市',
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87)),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: () => controller.selectCity(),
          child: Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_rounded,
                    color: Theme.of(context).primaryColor, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Obx(() {
                    final city = controller.selectedCity;
                    return Text(
                      city != null && city.name.isNotEmpty
                          ? city.name
                          : '请选择意向合作城市',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: city != null && city.name.isNotEmpty
                            ? Colors.black87
                            : Colors.grey[400],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 20.sp, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── 状态选择 ──
  Widget _buildStatusSelector(BuildContext context) {
    return Obx(() => Row(
          children: [
            _buildStatusOption(1, '上架', Icons.check_circle_outline),
            SizedBox(width: 16.w),
            _buildStatusOption(0, '下架', Icons.cancel_outlined),
          ],
        ));
  }

  Widget _buildStatusOption(int value, String label, IconData icon) {
    final selected = controller.status == value;
    return GestureDetector(
      onTap: () => controller.updateStatus(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(Get.context!).primaryColor.withOpacity(0.08)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected
                ? Theme.of(Get.context!).primaryColor
                : Colors.grey[200]!,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18.sp,
                color: selected
                    ? Theme.of(Get.context!).primaryColor
                    : Colors.grey[400]),
            SizedBox(width: 6.w),
            Text(label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? Theme.of(Get.context!).primaryColor
                      : Colors.grey[500],
                )),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 时间段
  // ═══════════════════════════════════════════
  Widget _buildTimeSlotSection(BuildContext context) {
    return Column(
      children: [
        _buildSectionLabel('星期时间段'),
        SizedBox(height: 6.h),
        _buildWeekdaySlots(context),
        SizedBox(height: 16.h),
        _buildSectionLabel('特殊日期'),
        SizedBox(height: 6.h),
        _buildSpecialDateSlots(context),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text,
        style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600]));
  }

  Widget _buildWeekdaySlots(BuildContext context) {
    return Obx(() => Column(
          children: List.generate(7, (i) {
            final weekday = i + 1;
            final slots = controller.slotsForWeekday(weekday);
            final allIndices = <int>[];
            for (var k = 0; k < controller.weekdaySlots.length; k++) {
              if (controller.weekdaySlots[k]['weekday'] == weekday)
                allIndices.add(k);
            }
            final hasSlots = slots.isNotEmpty;
            return Container(
              margin: EdgeInsets.only(bottom: 4.h),
              decoration: BoxDecoration(
                color: hasSlots
                    ? Theme.of(context).primaryColor.withOpacity(0.03)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(8.r),
                border: hasSlots
                    ? Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.15))
                    : null,
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.symmetric(horizontal: 12.w),
                visualDensity: VisualDensity.compact,
                title: Text(ProviderServiceController.weekdayLabels[i],
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.w500)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(slots.isEmpty ? '未设置' : '${slots.length}个时段',
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: hasSlots
                                ? Theme.of(context).primaryColor
                                : Colors.grey[400])),
                    SizedBox(width: 4.w),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20.sp, color: Colors.grey[400]),
                  ],
                ),
                childrenPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
                children: [
                  ...allIndices.map((idx) {
                    final s = controller.weekdaySlots[idx];
                    return _buildTimeRow(
                      context,
                      start: (s['startTime'] as String).substring(0, 5),
                      end: (s['endTime'] as String).substring(0, 5),
                      onStart: (t) => controller.updateWeekdaySlot(
                          idx, 'startTime', '$t:00'),
                      onEnd: (t) =>
                          controller.updateWeekdaySlot(idx, 'endTime', '$t:00'),
                      onDelete: () => controller.removeWeekdaySlot(idx),
                    );
                  }),
                  _buildAddSlotBtn(() => controller.addWeekdaySlot(weekday)),
                ],
              ),
            );
          }),
        ));
  }

  Widget _buildSpecialDateSlots(BuildContext context) {
    return Obx(() => Column(
          children: [
            ...controller.specialDateSlots.asMap().entries.map((e) {
              final s = e.value;
              return Container(
                margin: EdgeInsets.only(bottom: 4.h),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.orange.withOpacity(0.2)),
                ),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(horizontal: 12.w),
                  visualDensity: VisualDensity.compact,
                  title: Text(s['specialDate'] as String,
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w500)),
                  childrenPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
                  children: [
                    _buildTimeRow(
                      context,
                      start: (s['startTime'] as String).substring(0, 5),
                      end: (s['endTime'] as String).substring(0, 5),
                      onStart: (t) => controller.updateSpecialDateSlot(
                          e.key, 'startTime', '$t:00'),
                      onEnd: (t) => controller.updateSpecialDateSlot(
                          e.key, 'endTime', '$t:00'),
                      onDelete: () => controller.removeSpecialDateSlot(e.key),
                    ),
                  ],
                ),
              );
            }),
            _buildAddSlotBtn(() async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 365)));
              if (picked != null) {
                final dateStr =
                    '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                controller.addSpecialDateSlot(dateStr);
              }
            }),
          ],
        ));
  }

  Widget _buildTimeRow(BuildContext context,
      {required String start,
      required String end,
      required ValueChanged<String> onStart,
      required ValueChanged<String> onEnd,
      required VoidCallback onDelete}) {
    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          _buildTimeTap(context, start, onStart),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Text('—',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[400])),
          ),
          _buildTimeTap(context, end, onEnd),
          const Spacer(),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08), shape: BoxShape.circle),
              child: Icon(Icons.close, size: 14.sp, color: Colors.red[300]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTap(
      BuildContext context, String time, ValueChanged<String> onChanged) {
    return GestureDetector(
      onTap: () async {
        final parts = time.split(':');
        final t = await showTimePicker(
          context: context,
          initialTime:
              TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
        );
        if (t != null) {
          onChanged(
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(time,
            style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildAddSlotBtn(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          border:
              Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 16.sp, color: Colors.grey[500]),
            SizedBox(width: 4.w),
            Text('添加时间段',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}
