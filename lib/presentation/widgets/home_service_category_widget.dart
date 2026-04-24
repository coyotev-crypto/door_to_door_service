import 'package:flutter/material.dart';
import '../../core/utils/screen_adapter.dart';

class HomeServiceCategoryWidget extends StatelessWidget {
  final List<CategoryItem> categories;
  final Function(int) onCategoryTap;

  const HomeServiceCategoryWidget({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                TextButton(
                  onPressed: () {
                    // TODO: 跳转到更多推荐页面
                  },
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
          SizedBox(height: 12.h),

          // 分类网格
          Container(
            height: 200.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.0,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () => onCategoryTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 分类图标
                      Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          category.icon,
                          color: category.color,
                          size: 28.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      // 分类名称
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;

  CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
  });
}
