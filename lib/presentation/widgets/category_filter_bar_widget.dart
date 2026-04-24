import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/models/category_item.dart';

/// 分类筛选导航栏 Widget
class CategoryFilterBarWidget extends StatelessWidget {
  final List<CategoryItem> categories;
  final int selectedIndex;
  final Function(int) onCategorySelected;
  final bool hasFilter;
  final int filteredCount;

  const CategoryFilterBarWidget({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
    this.hasFilter = false,
    this.filteredCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          // 分类标签（可滚动）
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // 分类标签
                  ...List.generate(categories.length, (index) {
                    final category = categories[index];
                    final isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () => onCategorySelected(index),
                      child: Container(
                        margin: EdgeInsets.only(right: 12.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }
}
