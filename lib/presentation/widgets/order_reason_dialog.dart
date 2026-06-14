import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../core/utils/toast_util.dart';
import '../controllers/order_list_controller.dart';

/// 订单原因选择弹窗类型
enum OrderReasonType { cancel, refund }

/// 通用订单原因选择底部弹窗（取消订单 / 申请退款）
class OrderReasonDialog extends StatefulWidget {
  final int orderId;
  final OrderReasonType type;

  const OrderReasonDialog({
    super.key,
    required this.orderId,
    required this.type,
  });

  /// 显示取消订单弹窗
  static Future<void> showCancel(int orderId) {
    return Get.bottomSheet(
      OrderReasonDialog(orderId: orderId, type: OrderReasonType.cancel),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  /// 显示申请退款弹窗
  static Future<void> showRefund(int orderId) {
    return Get.bottomSheet(
      OrderReasonDialog(orderId: orderId, type: OrderReasonType.refund),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  State<OrderReasonDialog> createState() => _OrderReasonDialogState();
}

class _OrderReasonDialogState extends State<OrderReasonDialog> {
  static const _cancelReasons = [
    '不想要了',
    '误操作 / 重复下单',
    '暂时不需要此服务',
    '其他原因',
  ];

  static const _refundReasons = [
    '不需要此服务',
    '误操作 / 重复下单',
    '价格不合理',
    '其他原因',
  ];

  List<String> get _reasons =>
      widget.type == OrderReasonType.cancel ? _cancelReasons : _refundReasons;

  bool get _isCancel => widget.type == OrderReasonType.cancel;

  String get _title => _isCancel ? '取消订单' : '申请退款';
  String get _subtitle =>
      _isCancel ? '请选择取消原因，我们会根据原因优化服务体验' : '请选择退款原因，我们会尽快处理您的申请';
  String get _submitText => _isCancel ? '确认取消' : '提交申请';
  String get _cancelText => '再想想';
  String get _emptyHint => _isCancel ? '请选择或填写取消原因' : '请选择或填写退款原因';

  Color get _accentColor => _isCancel ? AppTheme.danger : AppTheme.gold;
  Gradient get _submitGradient => _isCancel
      ? const LinearGradient(colors: [AppTheme.danger, Color(0xFFC0392B)])
      : const LinearGradient(colors: [AppTheme.gold, AppTheme.amber]);

  late final TextEditingController _reasonCtl =
      TextEditingController(text: _reasons.first);
  late final RxString _selectedReason = _reasons.first.obs;
  final _isSubmitting = false.obs;

  @override
  void dispose() {
    _reasonCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 拖拽指示条
          Center(
            child: Container(
              width: 40.w, height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: AppTheme.warmBorder,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          // 标题
          Text(_title,
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          SizedBox(height: 6.h),
          Text(_subtitle,
              style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted)),
          SizedBox(height: 16.h),
          // 原因选项
          ..._reasons.map(_buildReasonItem),
          SizedBox(height: 8.h),
          // 补充说明
          TextField(
            controller: _reasonCtl,
            maxLines: 3,
            style: TextStyle(fontSize: 13.sp, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: '补充说明（选填）',
              hintStyle: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted),
              filled: true,
              fillColor: AppTheme.creamBg,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: _accentColor, width: 1.5),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          // 按钮
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: _isSubmitting.value ? null : () => Get.back(),
                child: Container(
                  height: 46.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.warmBorder, width: 1.5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(_cancelText,
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary)),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(child: _buildSubmitButton()),
          ]),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    ));
  }

  Widget _buildReasonItem(String reason) {
    final active = _selectedReason.value == reason;
    return GestureDetector(
      onTap: _isSubmitting.value
          ? null
          : () {
              _selectedReason.value = reason;
              _reasonCtl.text = reason;
            },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: active
              ? _accentColor.withValues(alpha: 0.06)
              : AppTheme.creamBg,
          border: Border.all(
            color: active ? _accentColor : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(children: [
          Expanded(
            child: Text(reason,
                style: TextStyle(
                    fontSize: 14.sp,
                    color: active ? _accentColor : AppTheme.textSecondary,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
          ),
          if (active)
            Icon(Icons.check_circle, size: 18.sp, color: _accentColor),
        ]),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isSubmitting.value ? null : _onSubmit,
      child: Container(
        height: 46.h,
        decoration: BoxDecoration(
          gradient: _submitGradient,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: _isSubmitting.value
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text(_submitText,
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (_reasonCtl.text.isEmpty) {
      ToastUtil.showError(_emptyHint);
      return;
    }
    _isSubmitting.value = true;
    final controller = Get.find<OrderListController>();
    final bool success;
    if (_isCancel) {
      success =
          await controller.cancelUserOrder(widget.orderId, _reasonCtl.text);
    } else {
      success = await controller.requestRefund(widget.orderId, _reasonCtl.text);
    }
    _isSubmitting.value = false;
    if (success) Get.back();
  }
}
