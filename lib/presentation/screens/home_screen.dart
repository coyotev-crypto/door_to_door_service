import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_content_widget.dart';
import '../widgets/home_bottom_nav_widget.dart';
import '../widgets/message_page_widget.dart';
import '../../core/utils/screen_adapter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            child: Stack(
              children: [
                // 页面内容
                Padding(
                  padding: EdgeInsets.only(
                      bottom: 60.h + MediaQuery.of(context).padding.bottom),
                  child: PageView(
                    controller: controller.pageController,
                    onPageChanged: (index) {
                      controller.changePage(index);
                    },
                    children: [
                      // 首页
                      HomeContentWidget(
                        onRefresh: () async {
                          await controller.refreshHome();
                        },
                        isRefreshing: controller.isLoading.value,
                      ),
                      // 社交页面
                      _buildSocialPage(),
                      // 消息页面
                      const MessagePageWidget(),
                      // 我的页面
                      _buildPlaceholderPage('我的'),
                    ],
                  ),
                ),
                // 底部导航栏
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Obx(() => HomeBottomNavWidget(
                        currentIndex: controller.currentIndex.value,
                        onTap: (index) {
                          controller.changePage(index);
                        },
                      )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建社交页面（类似朋友圈）
  Widget _buildSocialPage() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '朋友圈',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt_outlined,
                size: 24.sp, color: Colors.black87),
            onPressed: () {
              // TODO: 打开发布动态页面
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 10, // 模拟数据数量
        itemBuilder: (context, index) {
          return _buildSocialPost(index);
        },
      ),
    );
  }

  /// 构建单条社交动态
  Widget _buildSocialPost(int index) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息
          Row(
            children: [
              // 用户头像
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage('https://via.placeholder.com/48'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // 用户昵称和时间
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '用户$index',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '2小时前',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              // 更多选项
              Icon(Icons.more_horiz, size: 24.sp, color: Colors.grey[600]),
            ],
          ),
          SizedBox(height: 12.h),
          // 动态内容
          Text(
            '这是第$index条动态内容，展示用户分享的服务体验和生活点滴。',
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          SizedBox(height: 12.h),
          // 动态图片（网格布局）
          _buildPostImages(),
          SizedBox(height: 12.h),
          // 点赞和评论
          Row(
            children: [
              // 点赞按钮
              Icon(
                Icons.favorite_border,
                size: 20.sp,
                color: Colors.grey[600],
              ),
              SizedBox(width: 4.w),
              Text(
                '${index * 10 + 5}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(width: 16.w),
              // 评论按钮
              Icon(
                Icons.comment_outlined,
                size: 20.sp,
                color: Colors.grey[600],
              ),
              SizedBox(width: 4.w),
              Text(
                '${index * 5 + 2}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建动态图片网格
  Widget _buildPostImages() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 4.h,
        childAspectRatio: 1,
      ),
      itemCount: 3, // 模拟图片数量
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            image: DecorationImage(
              image: NetworkImage('https://via.placeholder.com/200'),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderPage(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_rounded,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            '$title页面开发中',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
