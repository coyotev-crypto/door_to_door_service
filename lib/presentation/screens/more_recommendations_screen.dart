import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../controllers/more_recommendations_controller.dart';
import '../controllers/service_controller.dart';
import '../widgets/service_card_widget.dart';
import '../widgets/empty_placeholder_widget.dart';
import '../../core/utils/screen_adapter.dart';

/// 更多推荐页面
/// 展示更多新人推荐服务列表
class MoreRecommendationsScreen extends GetView<MoreRecommendationsController> {
  const MoreRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('更多推荐'),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading && controller.services.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.services.isEmpty) {
          return const EmptyPlaceholderWidget(
            message: '暂无推荐服务',
          );
        }

        return EasyRefresh(
          controller: controller.refreshController,
          onRefresh: _onRefresh,
          onLoad: _onLoad,
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
    );
  }



  /// 下拉刷新
  Future<void> _onRefresh() async {
    try {
      await controller.refreshServices();
    } catch (e) {
      if (Get.context?.mounted == true) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(content: Text('刷新失败: $e')),
        );
      }
    }
  }

  /// 上拉加载
  Future<void> _onLoad() async {
    try {
      await controller.loadMoreServices();
    } catch (e) {
      if (Get.context?.mounted == true) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(content: Text('加载更多失败: $e')),
        );
      }
    }
  }
}
