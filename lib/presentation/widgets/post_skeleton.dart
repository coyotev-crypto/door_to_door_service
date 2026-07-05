import 'package:flutter/material.dart';
import '../../core/utils/screen_adapter.dart';

/// 帖子卡片骨架屏
class PostSkeleton extends StatelessWidget {
  const PostSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(12.r)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 5.h),
                Container(
                  height: 10.h,
                  width: 150.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 7.h),
                Row(
                  children: [
                    CircleAvatar(radius: 8.r, backgroundColor: Colors.grey[200]),
                    SizedBox(width: 6.w),
                    Container(
                      height: 8.h,
                      width: 60.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
