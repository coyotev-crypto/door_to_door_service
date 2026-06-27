import 'package:dtd/core/config/app_config.dart';
import 'package:dtd/core/services/app_update_service.dart';
import 'package:dtd/core/utils/log_util.dart';
import 'package:dtd/presentation/widgets/app_update_dialog.dart';
import 'package:dtd/presentation/screens/chat/conversations_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/auth_service.dart';
import '../../core/themes/app_theme.dart';
import '../../core/utils/screen_adapter.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_bottom_nav_widget.dart';
import 'account/profile_widget.dart';
import 'community/post_list_page.dart';
import 'home_content_widget.dart';
import 'order/provider_order_list_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late final HomeController _controller;
  final Map<int, Widget> _pageCache = <int, Widget>{};
  final Set<int> _loadedPages = <int>{0}; // 记录已加载的页面索引，默认加载首页

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = Get.find<HomeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAppUpdate();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAppUpdate();
    }
  }

  Future<void> _checkAppUpdate() async {
    final result = await AppUpdateService.instance.checkForUpdate();
    if (!mounted || result == null || !result.hasUpdate) return;
    await AppUpdateDialog.show(result);
  }

  Widget _buildPageByIndex(int index) {
    switch (index) {
      case 0:
        return Obx(() {
          final user = AuthService.instance.userRx.value;
          LogUtil.d('当前用户角色ID: ${user?.roleId}', tag: 'HomeScreen');
          if (user?.roleId == AppConfig.MERCHANT_USER_TYPE) {
            return const ProviderOrderListPage();
          }
          return HomeContentWidget(
            onRefresh: () async {
              await _controller.refreshHome();
            },
            isRefreshing: _controller.isLoading.value,
          );
        });
      case 1:
        return const PostListPage();
      case 2:
        return const ConversationsScreen();
      case 3:
        return ProfileWidget();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppTheme.creamBg,
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              // 页面内容
              Padding(
                padding: EdgeInsets.only(
                    bottom: 60.h + MediaQuery.of(context).padding.bottom),
                child: PageView.builder(
                  controller: _controller.pageController,
                  onPageChanged: (index) {
                    _controller.currentIndex.value = index;
                    // 标记页面已加载，触发重建以显示真实内容
                    if (_loadedPages.add(index)) {
                      setState(() {});
                    }
                  },
                  itemCount: 4,
                  itemBuilder: (_, index) {
                    // 只有当页面已被访问过才构建真实内容，否则返回占位符
                    if (!_loadedPages.contains(index)) {
                      return const SizedBox.shrink();
                    }
                    return _pageCache.putIfAbsent(
                      index,
                      () => _buildPageByIndex(index),
                    );
                  },
                ),
              ),
              // 底部导航栏
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Obx(() => HomeBottomNavWidget(
                      currentIndex: _controller.currentIndex.value,
                      onTap: (index) {
                        _controller.changePage(index);
                      },
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
