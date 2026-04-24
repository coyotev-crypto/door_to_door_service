import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import '../controllers/search_controller.dart' as search;
import '../controllers/service_controller.dart';
import '../widgets/service_card_widget.dart';
import '../widgets/empty_placeholder_widget.dart';
import '../../core/utils/screen_adapter.dart';

/// 搜索页面
class SearchScreen extends GetWidget<search.SearchController> {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: TextField(
            controller: controller.searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '搜索服务',
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
              isDense: true,
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey[500],
                size: 20.sp,
              ),
            ),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              controller.performSearch(value);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 获取当前TextField的文本并执行搜索
              final text = controller.searchController.text.trim();
              if (text.isNotEmpty) {
                controller.performSearch(text);
              }
            },
            child: Text(
              '搜索',
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        // 如果还没有搜索，显示搜索历史
        if (!controller.hasSearched) {
          return _buildSearchHistory();
        }

        // 如果已经搜索，显示搜索结果
        return _buildSearchResults();
      }),
    );
  }

  /// 构建搜索历史
  Widget _buildSearchHistory() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索历史
          if (controller.searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '搜索历史',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => _showClearHistoryDialog(),
                  child: Text(
                    '清空',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: controller.searchHistory.map((keyword) {
                return _buildHistoryKeywordChip(keyword);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建搜索历史关键词标签
  Widget _buildHistoryKeywordChip(String keyword) {
    return GestureDetector(
      onTap: () => controller.removeSearchHistory(keyword),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              keyword,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.close,
              size: 14.sp,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  /// 显示清空搜索历史对话框
  void _showClearHistoryDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('清空搜索历史'),
        content: const Text('确定要清空所有搜索历史吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              controller.clearSearchHistory();
              Get.back();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 构建搜索结果
  Widget _buildSearchResults() {
    return Column(
      children: [
        // 搜索结果列表
        Expanded(
          child: Obx(() {
            // 显示加载中状态
            if (controller.isSearching) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // 显示空状态
            if (controller.services.isEmpty) {
              return const EmptyPlaceholderWidget(
                message: '没有找到相关服务',
              );
            }

            // 显示服务列表
            return EasyRefresh(
              controller: controller.refreshController,
              onRefresh: controller.refreshServices,
              onLoad: controller.loadMoreServices,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: controller.services.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey[200],
                ),
                itemBuilder: (context, index) {
                  final service = controller.services[index];
                  return ServiceCardWidget(
                    service: service,
                    onTap: () {
                      // TODO: 跳转到服务详情
                    },
                    onOrderTap: () {
                      // TODO: 跳转到下单页面
                    },
                    onFavoriteTap: () async {
                      try {
                        final serviceController = Get.find<ServiceController>();
                        await serviceController.toggleFavorite(
                          service.id,
                          !(service.isFavorite ?? false),
                        );
                      } catch (e) {
                        if (Get.context?.mounted == true) {
                          ScaffoldMessenger.of(Get.context!).showSnackBar(
                            SnackBar(content: Text('操作失败: $e')),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
