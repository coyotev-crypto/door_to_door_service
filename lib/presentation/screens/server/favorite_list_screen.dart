import 'package:door_to_door_service/presentation/controllers/service_controller.dart';
import 'package:door_to_door_service/presentation/widgets/service_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../../controllers/favorite_controller.dart';
import '../../widgets/empty_placeholder_widget.dart';
import '../../widgets/loading_indicator.dart';
import '../../../data/models/user_model.dart';
import '../../../core/services/auth_service.dart';

/// 收藏列表页面
class FavoriteListScreen extends StatefulWidget {
  const FavoriteListScreen({super.key});

  @override
  State<FavoriteListScreen> createState() => _FavoriteListScreenState();
}

class _FavoriteListScreenState extends State<FavoriteListScreen> {
  late final FavoriteController controller;
  final EasyRefreshController _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  @override
  void initState() {
    super.initState();
    controller = Get.find<FavoriteController>();
    _onRefresh();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    try {
      final authService = AuthService.instance;
      final UserModel? user = authService.user;
      if (user != null) {
        final userId = int.tryParse(user.id) ?? 0;
        if (userId > 0) {
          await controller.refreshFavorites(userId);
        }
      }
      _refreshController.finishRefresh();
    } catch (e) {
      _refreshController.finishRefresh();
    }
  }

  Future<void> _onLoad() async {
    if (controller.isLoading || !controller.hasMore) {
      _refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }

    try {
      final authService = AuthService.instance;
      final UserModel? user = authService.user;
      if (user != null) {
        final userId = int.tryParse(user.id) ?? 0;
        if (userId > 0) {
          await controller.loadMoreFavorites(userId);
        }
      }
      _refreshController.finishLoad(controller.hasMore
          ? IndicatorResult.success
          : IndicatorResult.noMore);
    } catch (e) {
      // 如果未登录或获取用户信息失败，使用默认用户ID
      await controller.loadMoreFavorites(1);
      _refreshController.finishLoad(IndicatorResult.fail);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading && controller.favorites.isEmpty) {
          return const Center(child: LoadingIndicator());
        }

        if (controller.favorites.isEmpty) {
          return const EmptyPlaceholderWidget(
            message: '暂无收藏',
            icon: Icons.favorite_border,
          );
        }

        return EasyRefresh(
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoad: _onLoad,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: controller.favorites.length,
            itemBuilder: (context, index) {
              final favorite = controller.favorites[index];
              return ServiceCardWidget(
                service: favorite.service,
                onTap: () {
                  // TODO: 跳转到服务详情页
                  Get.toNamed('/service/detail/${favorite.service.id}');
                },
                onOrderTap: () {
                  // TODO: 跳转到下单页
                  Get.toNamed('/order/create/${favorite.service.id}');
                },
                onFavoriteTap: () async {
                  final serviceController = Get.find<ServiceController>();
                  await serviceController.toggleFavorite(
                    favorite.service.id,
                    !(favorite.service.isFavorite ?? false),
                  );
                  // 从收藏列表中移除该项
                  controller.removeFavorite(favorite.service.id);
                },
              );
            },
          ),
        );
      }),
    );
  }
}
