import 'package:dtd/core/config/app_config.dart';
import 'package:dtd/core/services/auth_service.dart';
import 'package:dtd/core/utils/log_util.dart';
import 'package:dtd/core/utils/toast_util.dart';
import 'package:dtd/data/models/category_model.dart';
import 'package:dtd/data/repositories/category_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final String _tag = 'HomeController'; // 用于日志输出

  final CategoryRepository _categoryRepository = CategoryRepository();
  // 当前选中的底部导航索引
  final RxInt currentIndex = 0.obs;

  // 页面控制器
  final PageController pageController = PageController(initialPage: 0);

  // 是否正在加载
  final RxBool isLoading = false.obs;

  // 服务分类列表
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  // 当前选中的分类
  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);

  Worker? _roleWorker;

  @override
  void onInit() {
    super.onInit();
    if (!_isProvider) {
      loadHomeData();
    }
    _roleWorker = ever(AuthService.instance.userRx, (_) {
      if (!_isProvider && categories.isEmpty) {
        loadHomeData();
      }
    });
  }

  @override
  void onClose() {
    _roleWorker?.dispose();
    pageController.dispose();
    super.onClose();
  }

  /// 切换页面
  void changePage(int index) {
    LogUtil.d('切换到页面索引: $index', tag: _tag);
    // 如果已经是当前页面，则不执行切换
    if (currentIndex.value == index) return;

    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// 加载首页数据
  Future<void> loadHomeData() async {
    if (_isProvider) return;

    isLoading.value = true;
    try {
      // 加载服务分类
      final categoryResponse = await _categoryRepository.getPrimaryCategories();
      categories.value = categoryResponse.list ?? [];

      // 如果有分类且没有选中项，默认选中第一个
      if (categories.isNotEmpty && selectedCategory.value == null) {
        selectedCategory.value = categories.first;
      }
    } catch (e) {
      ToastUtil.showError('加载服务分类失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 刷新首页
  Future<void> refreshHome() async {
    await loadHomeData();
  }

  bool get _isProvider {
    return AuthService.instance.userRx.value?.roleId ==
        AppConfig.MERCHANT_USER_TYPE;
  }
}
