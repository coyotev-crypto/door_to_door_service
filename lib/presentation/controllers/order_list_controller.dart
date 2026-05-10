import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../../core/utils/log_util.dart';
import '../../core/utils/toast_util.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

/// 订单列表控制器
class OrderListController extends GetxController {
  final _repository = OrderRepository();
  final EasyRefreshController refreshController = EasyRefreshController(
      controlFinishRefresh: true, controlFinishLoad: true);

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt selectedTab = 0.obs; // 0=全部, 1=待支付, 2=进行中, 3=已完成

  static const pageSize = 10;
  bool _noMore = false;

  bool get hasMore => !_noMore;

  String? get _filterStatus {
    switch (selectedTab.value) {
      case 1: return 'pending';   // 待支付
      case 2: return 'in_progress'; // 进行中
      case 3: return 'completed';   // 已完成
      default: return null;          // 全部
    }
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is int) {
      selectedTab.value = args.clamp(0, 3);
    }
    onRefresh();
  }

  void switchTab(int index) {
    if (selectedTab.value == index) return;
    selectedTab.value = index;
    onRefresh();
  }

  Future<void> onRefresh() async {
    currentPage.value = 1;
    _noMore = false;
    isLoading.value = true;
    try {
      final response = await _repository.getOrderList(
        status: _filterStatus,
        pageIndex: 1,
        pageSize: pageSize,
      );
      if (response.isSuccess && response.data != null) {
        orders.value = response.data!;
        _noMore = response.data!.length < pageSize;
      }
    } catch (e) {
      LogUtil.e('加载订单失败: $e');
      ToastUtil.showError('加载订单失败');
    } finally {
      isLoading.value = false;
      refreshController.finishRefresh();
    }
  }

  Future<void> onLoadMore() async {
    if (!hasMore) {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }
    currentPage.value++;
    try {
      final response = await _repository.getOrderList(
        status: _filterStatus,
        pageIndex: currentPage.value,
        pageSize: pageSize,
      );
      if (response.isSuccess && response.data != null) {
        final newData = response.data!;
        orders.addAll(newData);
        _noMore = newData.length < pageSize;
      }
      refreshController.finishLoad(
          hasMore ? IndicatorResult.success : IndicatorResult.noMore);
    } catch (e) {
      currentPage.value--;
      refreshController.finishLoad(IndicatorResult.fail);
    }
  }
}
