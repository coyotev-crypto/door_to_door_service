import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/service_item.dart';
import 'empty_placeholder_widget.dart';

/// 新人推荐 Widget
class NewcomerRecommendationWidget extends StatelessWidget {
  final List<ServiceItem> services;
  final VoidCallback? onMorePressed;
  final Function(ServiceItem)? onServiceTap;

  const NewcomerRecommendationWidget({
    super.key,
    required this.services,
    this.onMorePressed,
    this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '新人推荐',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'NEW',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // 只在列表不为空时显示更多按钮
                if (services.isNotEmpty)
                  TextButton(
                    onPressed: onMorePressed,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '更多',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 服务卡片列表 - 以人为主的布局
          SizedBox(
            height: 200.h,
            child: services.isEmpty
                ? const EmptyPlaceholderWidget(
                    message: '暂无新人推荐',
                    iconSize: 60,
                    verticalPadding: 20,
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    cacheExtent: 5 * 180.w, // 缓存5个item的宽度
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return RepaintBoundary(
                        child: GestureDetector(
                        onTap: () => onServiceTap?.call(service),
                        child: Container(
                          width: 180.w,
                          margin: EdgeInsets.only(right: 12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 服务人员头像和基本信息
                              Expanded(
                                flex: 2,
                                child: Stack(
                                  children: [
                                    // 背景渐变
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.1),
                                            Colors.white,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16.r),
                                        ),
                                      ),
                                    ),
                                    // 服务人员头像
                                    Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 20.h),
                                        child: Container(
                                          width: 80.w,
                                          height: 80.w,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey[200],
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.person_rounded,
                                            size: 40.sp,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // 新人标签
                                    if (service.isNew)
                                      Positioned(
                                        top: 8.h,
                                        left: 8.w,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 4.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                          child: Text(
                                            '新人特惠',
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // 服务人员和服务信息
                              Padding(
                                padding: EdgeInsets.all(12.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // 服务人员姓名
                                    Text(
                                      service.providerName ?? '未命名',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    // 评分和收藏
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.star_rounded,
                                          size: 14.sp,
                                          color: Colors.orange,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          service.rating.toString(),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.favorite_rounded,
                                              size: 12.sp,
                                              color: Colors.grey[400],
                                            ),
                                            SizedBox(width: 2.w),
                                            Text(
                                              '${service.favoriteCount ?? 0}',
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    // 价格
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '¥${service.price.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                        if (service.originalPrice != null) ...[
                                          SizedBox(width: 8.w),
                                          Text(
                                            '¥${service.originalPrice?.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.grey[400],
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
