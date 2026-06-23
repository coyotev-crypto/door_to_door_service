import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../../core/utils/toast_util.dart';
import '../../../core/themes/app_theme.dart';
import '../../../routes/route_names.dart';
import '../../controllers/account_security_controller.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/primary_input_field.dart';

/// 账号注销 — 温润质感
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});
  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _smsController = TextEditingController();
  final _ctrl = Get.find<AccountSecurityController>();
  bool _loading = false, _canSend = true, _agreed = false;
  int _cd = 60;
  Timer? _timer;

  @override
  void dispose() { _timer?.cancel(); _smsController.dispose(); super.dispose(); }

  void _sendSms() {
    if (!_canSend) return;
    setState(() { _canSend = false; _cd = 60; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() { if (_cd > 0) {
        _cd--;
      } else { _canSend = true; t.cancel(); } });
    });
    ToastUtil.showSuccess('验证码已发送');
  }

  Future<void> _submit() async {
    if (!_agreed) { ToastUtil.showError('请先阅读并同意注销协议'); return; }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await _ctrl.deleteAccount(smsCode: _smsController.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) Get.offAllNamed(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: const CommonAppBar(title: '账号注销'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
          children: [
            _warningCard(),
            SizedBox(height: 24.h),
            PrimaryInputField(
              controller: _smsController,
              label: '验证码',
              hintText: '请输入验证码',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              prefixIcon: const Icon(Icons.sms_outlined),
              validator: (v) => v == null || v.isEmpty ? '请输入验证码' : v.length != 6 ? '验证码长度应为6位' : null,
              trailingButton: GestureDetector(
                onTap: _canSend ? _sendSms : null,
                child: Container(
                  height: 40.h, width: 100.w,
                  decoration: BoxDecoration(
                    gradient: _canSend ? const LinearGradient(colors: [AppTheme.gold, AppTheme.amber]) : const LinearGradient(colors: [AppTheme.warmBorder, AppTheme.warmBorder]),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(child: Text(_canSend ? '获取验证码' : '${_cd}s',
                      style: TextStyle(fontSize: 13.sp, color: _canSend ? Colors.white : AppTheme.textMuted, fontWeight: FontWeight.w600))),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(children: [
              Transform.scale(scale: 0.85, child: Checkbox(value: _agreed, onChanged: (v) => setState(() => _agreed = v ?? false), activeColor: AppTheme.gold, side: const BorderSide(color: AppTheme.warmBorder, width: 1.5), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact)),
              Expanded(child: GestureDetector(onTap: () => setState(() => _agreed = !_agreed), child: Text('我已阅读并同意《账号注销协议》', style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary)))),
            ]),
            SizedBox(height: 32.h),
            _dangerBtn(),
          ],
        ),
      ),
    );
  }

  Widget _warningCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.danger.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.danger.withValues(alpha: 0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36.w, height: 36.w, decoration: BoxDecoration(color: AppTheme.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)), child: Icon(Icons.warning_amber_rounded, size: 18.sp, color: AppTheme.danger)),
          SizedBox(width: 10.w),
          Text('重要提示', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppTheme.danger)),
        ]),
        SizedBox(height: 12.h),
        Text('账号注销后，以下信息将被永久删除且无法恢复：', style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary)),
        SizedBox(height: 8.h),
        ...['账号信息和个人资料', '订单记录和交易信息', '收货地址和联系方式', '收藏和浏览记录', '其他所有与账号相关的数据']
            .map((s) => Padding(padding: EdgeInsets.only(top: 4.h), child: Text('· $s', style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted)))),
      ]),
    );
  }


  Widget _dangerBtn() {
    return GestureDetector(
      onTap: _loading ? null : _submit,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppTheme.danger, AppTheme.danger.withValues(alpha: 0.85)]),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [BoxShadow(color: AppTheme.danger.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Center(child: _loading
            ? SizedBox(width: 22.w, height: 22.w, child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Text('确认注销', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.5))),
      ),
    );
  }
}
