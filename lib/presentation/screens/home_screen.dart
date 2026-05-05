import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'home_content_widget.dart';
import '../widgets/home_bottom_nav_widget.dart';
import 'chat/message_page_widget.dart';
import 'account/profile_widget.dart';
import '../../core/utils/screen_adapter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  late final HomeController _controller;
  final Map<int, Widget> _pageCache = <int, Widget>{};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<HomeController>();
  }

  Widget _buildPageByIndex(int index) {
    switch (index) {
      case 0:
        return HomeContentWidget(
          onRefresh: () async {
            await _controller.refreshHome();
          },
          isRefreshing: _controller.isLoading.value,
        );
      case 1:
        return Container();
      case 2:
        return const MessagePageWidget();
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
      backgroundColor: Colors.grey[50],
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
                  },
                  itemCount: 4,
                  itemBuilder: (_, index) {
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
