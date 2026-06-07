import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/service_item.dart';
import '../../core/themes/app_theme.dart';

/// 服务卡片 — 温润质感风格
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
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: const BoxDecoration(color: Colors.white),
          child: Row(
            children: [
              // 头像图片
              Container(
                width: 84.w,
                height: 84.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.gold.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3)),
                    ]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: service.avatar != null && service.avatar!.isNotEmpty
                      ? Image.network(service.avatar!,
                          fit: BoxFit.cover,
                          cacheWidth: 256,
                          errorBuilder: (_, __, ___) => _placeholder())
                      : _placeholder(),
                ),
              ),
              SizedBox(width: 14.w),
              // 信息区
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 服务商名 + 距离
                    Row(
                      children: [
                        Expanded(
                          child: Text(service.providerName ?? '服务人员',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary)),
                        ),
                        if (service.distance != null &&
                            service.distance!.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF5F0E8),
                                borderRadius: BorderRadius.circular(4.r)),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.location_on_rounded,
                                  size: 10.sp, color: AppTheme.leather),
                              SizedBox(width: 2.w),
                              Text(service.distance!,
                                  style: TextStyle(
                                      fontSize: 10.sp,
                                      color: AppTheme.leather)),
                            ]),
                          ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    // 服务名称
                    Text(service.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13.sp, color: AppTheme.textSecondary)),
                    SizedBox(height: 6.h),
                    // 评分 · 单数 · 收藏
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            size: 13.sp, color: AppTheme.gold),
                        SizedBox(width: 2.w),
                        Text('${service.rating}',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: AppTheme.textSecondary)),
                        SizedBox(width: 10.w),
                        Text('${service.orderCount}单',
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: AppTheme.textMuted)),
                        SizedBox(width: 10.w),
                        Icon(Icons.favorite_rounded,
                            size: 11.sp, color: AppTheme.rose),
                        SizedBox(width: 2.w),
                        Text('${service.favoriteCount ?? 0}',
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: AppTheme.textMuted)),
                        const Spacer(),
                        GestureDetector(
                          onTap: onFavoriteTap,
                          child: Icon(
                            service.isFavorite == true
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18.sp,
                            color: service.isFavorite == true
                                ? AppTheme.rose
                                : const Color(0xFFD0C8BF),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // 价格 + 下单按钮
                    Row(
                      children: [
                        Text('¥${service.price}',
                            style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.gold)),
                        SizedBox(width: 4.w),
                        Text('/${service.defaultDurationMinutes}分钟',
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: AppTheme.textMuted)),
                        if (service.travelFeeValue != null &&
                            service.travelFeeValue! > 0) ...[
                          SizedBox(width: 6.w),
                          Text('出行¥${service.travelFee!}',
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  color: AppTheme.textMuted)),
                        ],
                        const Spacer(),
                        GestureDetector(
                          onTap: onOrderTap,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 7.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                AppTheme.gold,
                                AppTheme.amber
                              ]),
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                    color: AppTheme.gold
                                        .withValues(alpha: 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2))
                              ],
                            ),
                            child: Text('去下单',
                                style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
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
  }

  Widget _placeholder() {
    return Container(
      color: AppTheme.creamFill,
      child: Center(
          child: Icon(Icons.spa_rounded,
              size: 36.sp, color: const Color(0xFFD0C8BF))),
    );
  }
}
