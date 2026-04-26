import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/service_item.dart';

/// 服务卡片 Widget
class ServiceCardWidget extends StatelessWidget {
  final ServiceItem service;
  final VoidCallback? onTap;
  final VoidCallback? onOrderTap;
  final VoidCallback? onFavoriteTap;

  const ServiceCardWidget({
    super.key,
    required this.service,
    this.onTap,
    this.onOrderTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            // 服务图片
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.spa_rounded,
                      size: 40.sp,
                      color: Colors.grey[400],
                    ),
                  ),
                  if (service.isNew)
                    Positioned(
                      top: 4.h,
                      left: 4.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          '新人特惠',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 服务人员信息
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 服务人员名称和距离
                    Row(
                      children: [
                        Text(
                          service.providerName ?? '服务人员',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 10.sp,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                '${service.distance ?? '0.5'}km',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    // 服务项目名称
                    Text(
                      service.name,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    // 评分和收藏
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14.sp,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${service.rating}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${service.orderCount ?? 1000}单',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Row(
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              size: 12.sp,
                              color: Colors.grey[400],
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              '${service.favoriteCount ?? 500}人收藏',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: onFavoriteTap,
                          child: Icon(
                            service.isFavorite ?? false
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18.sp,
                            color: service.isFavorite ?? false
                                ? Colors.red
                                : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // 价格和出行费用
                    Row(
                      children: [
                        Text(
                          '¥${service.price}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        if (service.travelFee != null) ...[
                          SizedBox(width: 8.w),
                          Text(
                            '出行费¥${service.travelFee}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                        Spacer(),
                        // 去下单按钮
                        GestureDetector(
                          onTap: onOrderTap,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Text(
                              '去下单',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
