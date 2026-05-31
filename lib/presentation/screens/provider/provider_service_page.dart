import 'package:door_to_door_service/data/models/category_model.dart';
import 'package:door_to_door_service/presentation/controllers/provider_service_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../widgets/primary_button.dart';

/// 服务商完善服务页面 — 温润质感风格
class ProviderServicePage extends GetView<ProviderServiceController> {
  const ProviderServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      appBar: AppBar(
        title: Text(
          controller.isEditMode ? '编辑服务' : '完善服务',
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D2A26)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildForm(context, theme);
      }),
    );
  }

  Widget _buildForm(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 40.h),
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            _buildCard([
              _cardHeader('基本信息', Icons.spa_rounded, const Color(0xFFB8860B)),
              SizedBox(height: 20.h),
              _field('服务名称', '给服务取个名字', controller.nameController,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '请输入服务名称' : null),
              SizedBox(height: 16.h),
              _buildCategorySelector(context),
              SizedBox(height: 16.h),
              _field('服务商名称', '请输入您的姓名或昵称', controller.providerNameController,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '请输入服务商名称' : null),
            ]),
            SizedBox(height: 14.h),
            _buildCard([
              _cardHeader(
                  '服务区域', Icons.location_on_outlined, const Color(0xFF8B6914)),
              SizedBox(height: 20.h),
              _buildCitySelector(context),
              SizedBox(height: 16.h),
              _field('配送范围（KM）', '可服务的最大距离', controller.deliveryRangeController,
                  keyboardType: TextInputType.number, validator: (v) {
                if (v == null || v.trim().isEmpty) return '请输入配送范围';
                final r = double.tryParse(v);
                if (r == null || r <= 0) return '请输入有效的范围';
                return null;
              }),
            ]),
            SizedBox(height: 14.h),
            _buildCard([
              _cardHeader(
                  '可服务时间', Icons.wb_twilight_rounded, const Color(0xFF9B7653)),
              SizedBox(height: 16.h),
              _buildTimeSlotSection(context),
            ]),
            SizedBox(height: 14.h),
            _buildCard([
              _cardHeader(
                  '价格方案', Icons.auto_awesome_rounded, const Color(0xFFC4956A)),
              SizedBox(height: 16.h),
              _buildPricesEditor(context),
            ]),
            SizedBox(height: 36.h),
            Obx(() => PrimaryButton(
                  text: controller.isEditMode ? '保存修改' : '提交服务',
                  isLoading: controller.isSubmitting,
                  onPressed: controller.submit,
                )),
          ],
        ),
      ),
    );
  }

  // ═══ 卡片 ═══
  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF2D2A26).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _cardHeader(String title, IconData icon, Color accent) {
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10.r)),
          child: Icon(icon, size: 20.sp, color: accent),
        ),
        SizedBox(width: 12.w),
        Text(title,
            style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D2A26))),
      ],
    );
  }

  // ═══ 输入框 ═══
  Widget _field(String label, String hint, TextEditingController ctrl,
      {TextInputType? keyboardType, FormFieldValidator<String>? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B5E53))),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9F7F4),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE8E2D8)),
          ),
          child: TextFormField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 15.sp, color: const Color(0xFF2D2A26)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  TextStyle(fontSize: 15.sp, color: const Color(0xFFB8A99A)),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              isCollapsed: true,
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  // ═══ 分类选择 ═══
  Widget _buildCategorySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('服务分类',
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B5E53))),
        SizedBox(height: 6.h),
        Obx(() {
          return Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F7F4),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE8E2D8)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CategoryModel>(
                value: controller.selectedCategory,
                isExpanded: true,
                hint: Text('选择分类',
                    style: TextStyle(
                        fontSize: 15.sp, color: const Color(0xFFB8A99A))),
                icon: Icon(Icons.expand_more_rounded,
                    size: 22.sp, color: const Color(0xFFB8A99A)),
                style:
                    TextStyle(fontSize: 15.sp, color: const Color(0xFF2D2A26)),
                items: controller.categories
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

  // ═══ 城市选择 ═══
  Widget _buildCitySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('意向合作城市',
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B5E53))),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: () => controller.selectCity(),
          child: Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F7F4),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE8E2D8)),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_rounded,
                    color: const Color(0xFFC4956A), size: 20.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Obx(() {
                    final c = controller.selectedCity;
                    return Text(
                        c != null && c.name.isNotEmpty ? c.name : '选择城市',
                        style: TextStyle(
                            fontSize: 15.sp,
                            color: c != null && c.name.isNotEmpty
                                ? const Color(0xFF2D2A26)
                                : const Color(0xFFB8A99A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis);
                  }),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 20.sp, color: const Color(0xFFB8A99A)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // 时间段编辑器
  // ═══════════════════════════════════════════
  Widget _buildTimeSlotSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('星期时间段'),
        SizedBox(height: 6.h),
        _buildWeekdaySlots(context),
        SizedBox(height: 16.h),
        _sectionLabel('特殊日期'),
        SizedBox(height: 6.h),
        _buildSpecialDateSlots(context),
      ],
    );
  }

  Widget _buildWeekdaySlots(BuildContext context) {
    return Obx(() => Column(
          children: List.generate(7, (i) {
            final w = i + 1;
            final slots = controller.slotsForWeekday(w);
            final indices = <int>[];
            for (var k = 0; k < controller.weekdaySlots.length; k++) {
              if (controller.weekdaySlots[k]['weekday'] == w) indices.add(k);
            }
            final hasSlots = slots.isNotEmpty;
            return Container(
              margin: EdgeInsets.only(bottom: 4.h),
              decoration: BoxDecoration(
                color: hasSlots
                    ? const Color(0xFFF5F0E8)
                    : const Color(0xFFF9F7F4),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.symmetric(horizontal: 14.w),
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
                collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
                title: Text(ProviderServiceController.weekdayLabels[i],
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.w600)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(slots.isEmpty ? '未设置' : '${slots.length}个',
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: hasSlots
                                ? const Color(0xFF9B7653)
                                : const Color(0xFFB8A99A))),
                    SizedBox(width: 4.w),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20.sp, color: const Color(0xFFB8A99A)),
                  ],
                ),
                childrenPadding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 10.h),
                children: [
                  ...indices.map((idx) {
                    final s = controller.weekdaySlots[idx];
                    return _timeRow(context,
                        start: (s['startTime'] as String).substring(0, 5),
                        end: (s['endTime'] as String).substring(0, 5),
                        onStart: (t) => controller.updateWeekdaySlot(
                            idx, 'startTime', '$t:00'),
                        onEnd: (t) => controller.updateWeekdaySlot(
                            idx, 'endTime', '$t:00'),
                        onDelete: () => controller.removeWeekdaySlot(idx));
                  }),
                  _addBtn(() => controller.addWeekdaySlot(w)),
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
                  color: const Color(0xFFFFF6ED),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(horizontal: 14.w),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  title: Text(s['specialDate'] as String,
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  childrenPadding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 10.h),
                  children: [
                    _timeRow(context,
                        start: (s['startTime'] as String).substring(0, 5),
                        end: (s['endTime'] as String).substring(0, 5),
                        onStart: (t) => controller.updateSpecialDateSlot(
                            e.key, 'startTime', '$t:00'),
                        onEnd: (t) => controller.updateSpecialDateSlot(
                            e.key, 'endTime', '$t:00'),
                        onDelete: () =>
                            controller.removeSpecialDateSlot(e.key)),
                  ],
                ),
              );
            }),
            _addBtn(() async {
              final now = DateTime.now();
              final p = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 365)));
              if (p != null) {
                controller.addSpecialDateSlot(
                    '${p.year}-${p.month.toString().padLeft(2, '0')}-${p.day.toString().padLeft(2, '0')}');
              }
            }),
          ],
        ));
  }

  Widget _timeRow(BuildContext context,
      {required String start,
      required String end,
      required ValueChanged<String> onStart,
      required ValueChanged<String> onEnd,
      required VoidCallback onDelete}) {
    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
      child: Row(
        children: [
          _timeTap(context, start, onStart),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Text('—',
                  style: TextStyle(
                      fontSize: 14.sp, color: const Color(0xFFB8A99A)))),
          _timeTap(context, end, onEnd),
          const Spacer(),
          GestureDetector(
            onTap: onDelete,
            child: Container(
                width: 30.w,
                height: 30.w,
                decoration: const BoxDecoration(
                    color: Color(0xFFF5E6E6), shape: BoxShape.circle),
                child: Icon(Icons.close,
                    size: 14.sp, color: const Color(0xFFC67B7B))),
          ),
        ],
      ),
    );
  }

  Widget _timeTap(
      BuildContext context, String time, ValueChanged<String> onChange) {
    return GestureDetector(
      onTap: () async {
        final parts = time.split(':');
        final t = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(
                hour: int.parse(parts[0]), minute: int.parse(parts[1])));
        if (t != null) {
          onChange(
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
            color: const Color(0xFFF9F7F4),
            borderRadius: BorderRadius.circular(8.r)),
        child: Text(time,
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D2A26))),
      ),
    );
  }

  Widget _addBtn(VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(top: 6.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE8E2D8)),
              borderRadius: BorderRadius.circular(10.r)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add_rounded,
                size: 18.sp, color: const Color(0xFF9B7653)),
            SizedBox(width: 4.w),
            Text('添加',
                style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF9B7653),
                    fontWeight: FontWeight.w500)),
          ]),
        ),
      );

  Widget _sectionLabel(String t) => Text(t,
      style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFB8A99A),
          letterSpacing: 0.5));

  // ═══════════════════════════════════════════
  // 多时长价格编辑器
  // ═══════════════════════════════════════════
  Widget _buildPricesEditor(BuildContext context) {
    return Obx(() => Column(
          children: [
            ...controller.prices.asMap().entries.map((e) {
              final p = e.value;
              final dur = p['durationMinutes']?.toString() ?? '60';
              final prc = (p['price'] as num?)?.toString() ?? '';
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                    color: const Color(0xFFF9F7F4),
                    borderRadius: BorderRadius.circular(10.r)),
                child: Row(
                  children: [
                    Container(
                      width: 48.w,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
                      child: TextFormField(
                        initialValue: dur,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D2A26)),
                        decoration: const InputDecoration(
                            isCollapsed: true, border: InputBorder.none),
                        onChanged: (v) => controller.updatePrice(
                            e.key, 'durationMinutes', int.tryParse(v) ?? 60),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text('分钟',
                            style: TextStyle(
                                fontSize: 13.sp,
                                color: const Color(0xFF9B7653),
                                fontWeight: FontWeight.w500))),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 10.h),
                        child: Row(children: [
                          Text('¥',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFC4956A))),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: TextFormField(
                              initialValue: prc,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2D2A26)),
                              decoration: const InputDecoration(
                                  isCollapsed: true,
                                  hintText: '0',
                                  border: InputBorder.none),
                              onChanged: (v) => controller.updatePrice(
                                  e.key, 'price', double.tryParse(v) ?? 0),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    GestureDetector(
                      onTap: () => controller.removePrice(e.key),
                      child: Container(
                          width: 30.w,
                          height: 30.w,
                          decoration: const BoxDecoration(
                              color: Color(0xFFF5E6E6), shape: BoxShape.circle),
                          child: Icon(Icons.close,
                              size: 14.sp, color: const Color(0xFFC67B7B))),
                    ),
                  ],
                ),
              );
            }),
            _addBtn(() => controller.addPrice()),
          ],
        ));
  }
}
