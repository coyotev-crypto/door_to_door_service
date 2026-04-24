import 'package:flutter/material.dart';
import '../../core/utils/screen_adapter.dart';

class AgreementCheckbox extends StatelessWidget {
  final bool agreed;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onUserAgreementTap;
  final VoidCallback onPrivacyPolicyTap;

  const AgreementCheckbox({
    super.key,
    required this.agreed,
    required this.onChanged,
    required this.onUserAgreementTap,
    required this.onPrivacyPolicyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: agreed,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 4.w, top: 6.h),
            child: Wrap(
              spacing: 4.w,
              runSpacing: 4.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('我已阅读并同意',
                    style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600])),
                TextButton(
                  onPressed: onUserAgreementTap,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('用户协议',
                      style: TextStyle(fontSize: 13.sp)),
                ),
                Text('和',
                    style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600])),
                TextButton(
                  onPressed: onPrivacyPolicyTap,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('隐私政策',
                      style: TextStyle(fontSize: 13.sp)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
