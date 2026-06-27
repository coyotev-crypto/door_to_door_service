import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/toast_util.dart';
import '../../controllers/wallet_controller.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/primary_input_field.dart';
import '../../widgets/primary_button.dart';

/// 支付宝账号绑定页面
/// 简化设计，仅保留核心账号信息输入
class BindAlipayScreen extends StatefulWidget {
  const BindAlipayScreen({super.key});

  @override
  State<BindAlipayScreen> createState() => _BindAlipayScreenState();
}

class _BindAlipayScreenState extends State<BindAlipayScreen> {
  final WalletController controller = Get.find<WalletController>();
  
  // 表单数据
  final TextEditingController _alipayAccountController = TextEditingController();
  final TextEditingController _confirmAlipayController = TextEditingController();
  final TextEditingController _realNameController = TextEditingController();

  bool _agreeTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _alipayAccountController.dispose();
    _confirmAlipayController.dispose();
    _realNameController.dispose();
    super.dispose();
  }

  // 支付宝账号正则校验（手机号或邮箱）
  bool _isValidAlipay(String value) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final phoneRegExp = RegExp(r'^1[3-9]\d{9}$');
    return emailRegExp.hasMatch(value) || phoneRegExp.hasMatch(value);
  }

  void _handleSubmit() async {
    final account = _alipayAccountController.text.trim();
    final confirmAccount = _confirmAlipayController.text.trim();
    final realName = _realNameController.text.trim();

    if (!_isValidAlipay(account)) {
      ToastUtil.showError('请输入正确的支付宝账号(手机号或邮箱)');
      return;
    }

    if (account != confirmAccount) {
      ToastUtil.showError('两次输入的账号不一致');
      return;
    }

    if (realName.isEmpty) {
      ToastUtil.showError('请输入真实姓名');
      return;
    }

    if (!_agreeTerms) {
      ToastUtil.showMessage('请先勾选确认收款账号信息准确无误');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await controller.bindPaymentAccount(
        accountName: realName,
        accountNo: account,
        method: 'alipay',
        isDefault: controller.paymentAccounts.isEmpty, // 如果是第一个账户，设为默认
      );
    } catch (e) {
      // 错误已在 controller 中处理
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: const CommonAppBar(title: '绑定支付宝'),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderTip(),
            SizedBox(height: 28.h),
            
            // 支付宝账号
            PrimaryInputField(
              label: '支付宝账户',
              hintText: '手机号或邮箱地址',
              controller: _alipayAccountController,
              prefixIcon: const Icon(Icons.account_circle_outlined),
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 20.h),

            // 确认账号
            PrimaryInputField(
              label: '确认支付宝账户',
              hintText: '请再次输入支付宝账户',
              controller: _confirmAlipayController,
              prefixIcon: const Icon(Icons.verified_user_outlined),
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 20.h),

            // 真实姓名
            PrimaryInputField(
              label: '收款方真实姓名',
              hintText: '须与支付宝实名认证姓名一致',
              controller: _realNameController,
              prefixIcon: const Icon(Icons.badge_outlined),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 24.h),

            // 协议勾选
            _buildTermsCheckbox(),
            SizedBox(height: 36.h),

            // 提交按钮
            PrimaryButton(
              text: '立即绑定',
              isLoading: _isLoading,
              onPressed: _isFormValid ? _handleSubmit : null,
              width: double.infinity,
            ),
            
            SizedBox(height: 20.h),
            _buildSafetyTip(),
          ],
        ),
      ),
    );
  }

  bool get _isFormValid {
    return _alipayAccountController.text.isNotEmpty &&
           _confirmAlipayController.text.isNotEmpty &&
           _realNameController.text.isNotEmpty;
  }

  Widget _buildHeaderTip() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppTheme.gold, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              '请务必核对收款信息，填写错误将导致提现失败或资金损失。',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return InkWell(
      onTap: () => setState(() => _agreeTerms = !_agreeTerms),
      child: Row(
        children: [
          SizedBox(
            width: 24.w,
            height: 24.h,
            child: Checkbox(
              value: _agreeTerms,
              onChanged: (v) => setState(() => _agreeTerms = v ?? false),
              activeColor: AppTheme.gold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '我已确认收款账号信息准确无误',
            style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTip() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 14.sp, color: AppTheme.textMuted),
          SizedBox(width: 4.w),
          Text(
            '您的信息将被严格加密，仅用于提现发放',
            style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
