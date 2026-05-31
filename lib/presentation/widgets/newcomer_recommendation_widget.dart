import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/service_item.dart';
import '../../core/themes/app_theme.dart';

/// 新人推荐 — 温润质感风格
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
          // 标题行
          Padding(
            padding: EdgeInsets.only(top: 16.h, bottom: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(width: 2.w, height: 18.h,
                      margin: EdgeInsets.only(bottom: 2.h),
                      decoration: BoxDecoration(
                        color: AppTheme.gold, borderRadius: BorderRadius.circular(1.r),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text('新人推荐',
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppTheme.gold, AppTheme.amber]),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text('NEW', style: TextStyle(fontSize: 9.sp, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                    ),
                  ],
                ),
                if (services.isNotEmpty)
                  GestureDetector(
                    onTap: onMorePressed,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('更多', style: TextStyle(fontSize: 13.sp, color: AppTheme.amber)),
                      SizedBox(width: 2.w),
                      Icon(Icons.chevron_right_rounded, size: 18.sp, color: AppTheme.amber),
                    ]),
                  ),
              ],
            ),
          ),
          // 卡片列表
          SizedBox(
            height: 210.h,
            child: ListView.builder(
              scrollCacheExtent: ScrollCacheExtent.pixels(5 * 172.w), scrollDirection: Axis.horizontal,
              itemCount: services.length,
              itemBuilder: (context, index) => _buildCard(context, services[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, ServiceItem service) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => onServiceTap?.call(service),
        child: Container(
          width: 172.w,
          margin: EdgeInsets.only(right: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [BoxShadow(color: AppTheme.gold.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 头像区
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Color(0xFFF5F0E8), Colors.white],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          width: 76.w, height: 76.w,
                          margin: EdgeInsets.only(top: 12.h),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [BoxShadow(color: AppTheme.textPrimary.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 3))],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: service.avatar != null && service.avatar!.isNotEmpty
                              ? Image.network(service.avatar!, fit: BoxFit.cover,
                                  cacheWidth: 256,
                                  errorBuilder: (_, __, ___) => _avatarPlaceholder())
                              : _avatarPlaceholder(),
                        ),
                      ),
                      if (service.isNew)
                        Positioned(
                          top: 10.h, left: 10.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppTheme.gold, AppTheme.amber]),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text('新人特惠', style: TextStyle(fontSize: 9.sp, color: Colors.white, fontWeight: FontWeight.w700)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // 信息区
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(service.providerName ?? '未命名',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star_rounded, size: 13.sp, color: AppTheme.gold),
                          SizedBox(width: 3.w),
                          Text(service.rating.toStringAsFixed(1),
                              style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary)),
                          SizedBox(width: 10.w),
                          Icon(Icons.favorite_rounded, size: 11.sp, color: AppTheme.rose),
                          SizedBox(width: 2.w),
                          Text('${service.favoriteCount ?? 0}',
                              style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted)),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('¥${service.price.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: AppTheme.gold)),
                        SizedBox(width: 3.w),
                        Text('/${service.defaultDurationMinutes}分钟',
                            style: TextStyle(fontSize: 10.sp, color: AppTheme.textMuted)),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      color: AppTheme.creamFill,
      child: Icon(Icons.person_rounded, size: 36.sp, color: const Color(0xFFD0C8BF)),
    );
  }
}
