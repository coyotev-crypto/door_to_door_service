import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_theme.dart';
import '../../widgets/common_app_bar.dart';

/// 支付宝账号绑定页面 - 参考支付宝、微信主流应用设计
/// 多步骤流程绑定支付宝账号
class BindAlipayScreen extends StatefulWidget {
  const BindAlipayScreen({super.key});

  @override
  State<BindAlipayScreen> createState() => _BindAlipayScreenState();
}

class _BindAlipayScreenState extends State<BindAlipayScreen> {
  // 绑定流程状态
  int currentStep = 0; // 0: 输入账号, 1: 验证信息, 2: 完成

  // 表单数据
  final TextEditingController _alipayAccountController = TextEditingController();
  final TextEditingController _realNameController = TextEditingController();
  final TextEditingController _idCardController = TextEditingController();
  final TextEditingController _verifyCodeController = TextEditingController();

  bool _agreeTerms = false;
  bool _isLoading = false;
  bool _showVerifyCode = false;
  int _verifyCountdown = 0;

  @override
  void dispose() {
    _alipayAccountController.dispose();
    _realNameController.dispose();
    _idCardController.dispose();
    _verifyCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      appBar: const CommonAppBar(title: '绑定支付宝'),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 流程步骤指示器
            _buildProgressSteps(),
            SizedBox(height: 28.h),
            // 根据当前步骤显示不同内容
            if (currentStep == 0) _buildStep1Content(),
            if (currentStep == 1) _buildStep2Content(),
            if (currentStep == 2) _buildStep3Content(),
          ],
        ),
      ),
    );
  }

  /// 流程步骤指示器
  Widget _buildProgressSteps() {
    return Row(
      children: [
        _buildStepIndicator(0, '账号信息'),
        SizedBox(width: 8.w),
        _buildConnector(0),
        SizedBox(width: 8.w),
        _buildStepIndicator(1, '身份验证'),
        SizedBox(width: 8.w),
        _buildConnector(1),
        SizedBox(width: 8.w),
        _buildStepIndicator(2, '绑定完成'),
      ],
    );
  }

  /// 步骤指示器圆圈
  Widget _buildStepIndicator(int step, String label) {
    bool isCompleted = currentStep > step;
    bool isCurrent = currentStep == step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: isCompleted || isCurrent ? AppTheme.gold : AppTheme.warmBorder,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check_rounded, color: Colors.white, size: 18.sp)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: isCurrent ? AppTheme.gold : AppTheme.textMuted,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 步骤连接线
  Widget _buildConnector(int step) {
    bool isCompleted = currentStep > step;
    return Expanded(
      child: Container(
        height: 2.h,
        color: isCompleted ? AppTheme.gold : AppTheme.warmBorder,
      ),
    );
  }

  /// 第一步：输入账号信息
  Widget _buildStep1Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 步骤标题
        Text(
          '请输入您的支付宝账号信息',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          '账号信息必须与已认证的支付宝账户一致',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppTheme.textMuted,
          ),
        ),
        SizedBox(height: 24.h),

        // 支付宝账号输入框
        _buildInputField(
          label: '支付宝账号',
          hint: '请输入支付宝账号或手机号',
          controller: _alipayAccountController,
          icon: Icons.account_balance_wallet_outlined,
        ),
        SizedBox(height: 16.h),

        // 真实姓��输入框
        _buildInputField(
          label: '真实姓名',
          hint: '请输入与支付宝一致的姓名',
          controller: _realNameController,
          icon: Icons.person_outline_rounded,
        ),
        SizedBox(height: 16.h),

        // 身份证号输入框
        _buildInputField(
          label: '身份证号码',
          hint: '请输入18位身份证号码',
          controller: _idCardController,
          icon: Icons.badge_outlined,
          inputType: TextInputType.number,
        ),
        SizedBox(height: 20.h),

        // 协议勾选
        _buildTermsCheckbox(),
        SizedBox(height: 28.h),

        // 下一步按钮
        _buildPrimaryButton(
          label: '下一步',
          onPressed: _alipayAccountController.text.isNotEmpty &&
                  _realNameController.text.isNotEmpty &&
                  _idCardController.text.isNotEmpty &&
                  _agreeTerms
              ? () {
                  setState(() => currentStep = 1);
                }
              : null,
        ),
        SizedBox(height: 12.h),

        // 返回按钮
        _buildSecondaryButton(
          label: '返回',
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  /// 第二步：身份验证
  Widget _buildStep2Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 步骤标题
        Text(
          '身份信息验证',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          '我们将向您的支付宝账号发送验证码，请查收后输入',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppTheme.textMuted,
          ),
        ),
        SizedBox(height: 24.h),

        // 验证信息展示卡片
        _buildVerificationInfoCard(),
        SizedBox(height: 24.h),

        // 验证码输入框（显示条件）
        if (_showVerifyCode) ...[
          Text(
            '验证码',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          _buildVerifyCodeInputField(),
          SizedBox(height: 24.h),
        ],

        // 操作按钮组
        if (!_showVerifyCode) ...[
          _buildPrimaryButton(
            label: '发送验证码',
            isLoading: _isLoading,
            onPressed: () {
              setState(() {
                _isLoading = true;
                _showVerifyCode = true;
              });
              // 模拟发送验证码
              Future.delayed(const Duration(milliseconds: 500), () {
                setState(() => _isLoading = false);
              });
            },
          ),
        ] else ...[
          _buildPrimaryButton(
            label: '验证并完成',
            isLoading: _isLoading,
            onPressed: _verifyCodeController.text.isNotEmpty
                ? () {
                    setState(() {
                      _isLoading = true;
                    });
                    // 模拟验证过程
                    Future.delayed(const Duration(milliseconds: 1500), () {
                      setState(() {
                        _isLoading = false;
                        currentStep = 2;
                      });
                    });
                  }
                : null,
          ),
        ],
        SizedBox(height: 12.h),

        // 返回按钮
        _buildSecondaryButton(
          label: '返回修改',
          onPressed: () {
            setState(() {
              currentStep = 0;
              _showVerifyCode = false;
            });
          },
        ),
      ],
    );
  }

  /// 验证信息展示卡片
  Widget _buildVerificationInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.warmBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVerificationItem('支付宝账号', _alipayAccountController.text),
          SizedBox(height: 12.h),
          Divider(color: AppTheme.warmBorder, height: 1),
          SizedBox(height: 12.h),
          _buildVerificationItem('真实姓名', _realNameController.text),
          SizedBox(height: 12.h),
          Divider(color: AppTheme.warmBorder, height: 1),
          SizedBox(height: 12.h),
          _buildVerificationItem('身份证号', _idCardController.text.replaceRange(
            6,
            _idCardController.text.length - 4,
            '*' * (_idCardController.text.length - 10),
          )),
        ],
      ),
    );
  }

  /// 验证项目行
  Widget _buildVerificationItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  /// 验证码输入框
  Widget _buildVerifyCodeInputField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _verifyCodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: '请输入6位验证码',
              hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13.sp),
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
                color: AppTheme.textMuted,
              ),
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: AppTheme.warmBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: AppTheme.warmBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: AppTheme.gold, width: 1.5),
              ),
            ),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          width: 90.w,
          height: 56.h,
          decoration: BoxDecoration(
            color: AppTheme.creamFill,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppTheme.warmBorder),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _verifyCountdown <= 0
                  ? () {
                      setState(() => _verifyCountdown = 60);
                      Future.delayed(const Duration(seconds: 1), _countdownTick);
                    }
                  : null,
              borderRadius: BorderRadius.circular(10.r),
              child: Center(
                child: Text(
                  _verifyCountdown <= 0 ? '重新获取' : '${_verifyCountdown}s',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: _verifyCountdown <= 0 ? AppTheme.gold : AppTheme.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 验证码倒计时
  void _countdownTick() {
    if (_verifyCountdown > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _verifyCountdown--);
          _countdownTick();
        }
      });
    }
  }

  /// 第三步：完成
  Widget _buildStep3Content() {
    return Column(
      children: [
        SizedBox(height: 40.h),

        // 成功图标
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: AppTheme.sage.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.check_circle_rounded,
              color: AppTheme.sage,
              size: 48.sp,
            ),
          ),
        ),
        SizedBox(height: 24.h),

        // 完成文本
        Text(
          '支付宝账号绑定成功',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),
        Text(
          '您已成功绑定支付宝账号，提现时将直接到账',
          style: TextStyle(
            fontSize: 13.sp,
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40.h),

        // 账号信息总结卡片
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.warmBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: AppTheme.creamFill,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Text('🅰️', style: TextStyle(fontSize: 24.sp)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '支付宝',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _alipayAccountController.text,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '默认账号',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 40.h),

        // 完成按钮
        _buildPrimaryButton(
          label: '完成',
          onPressed: () {
            Get.back();
          },
        ),
      ],
    );
  }

  /// 输入框组件
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: inputType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13.sp),
            prefixIcon: Icon(icon, color: AppTheme.textMuted),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppTheme.warmBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppTheme.warmBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppTheme.gold, width: 1.5),
            ),
          ),
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  /// 协议勾选框
  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          width: 24.w,
          height: 24.h,
          child: Checkbox(
            value: _agreeTerms,
            onChanged: (value) => setState(() => _agreeTerms = value ?? false),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
            activeColor: AppTheme.gold,
            checkColor: Colors.white,
            side: BorderSide(
              color: _agreeTerms ? AppTheme.gold : AppTheme.warmBorder,
              width: 2,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '我已阅读并同意',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
                TextSpan(
                  text: '《支付宝绑定协议》',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 主按钮
  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null ? AppTheme.gold : AppTheme.textMuted.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.h,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    onPressed != null ? Colors.white : AppTheme.textMuted,
                  ),
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: onPressed != null ? Colors.white : AppTheme.textMuted,
                ),
              ),
      ),
    );
  }

  /// 次要按钮
  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppTheme.warmBorder, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

