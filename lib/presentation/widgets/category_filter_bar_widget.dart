import 'package:flutter/material.dart';
import '../../core/utils/screen_adapter.dart';
import '../../data/models/category_model.dart';

/// 分类筛选导航栏组件
class CategoryFilterBarWidget extends StatelessWidget {
  /// 分类列表（首项为"全部"占位）
  final List<CategoryModel> categories;

  /// 选中的分类索引
  final int selectedIndex;

  /// 分类选中回调
  final Function(int) onCategorySelected;

  const CategoryFilterBarWidget({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(categories.length, (index) {
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
                  categories[index].name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
