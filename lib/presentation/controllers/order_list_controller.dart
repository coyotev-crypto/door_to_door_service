import 'package:door_to_door_service/core/config/app_config.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/loading_util.dart';
import '../../core/utils/toast_util.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

/// 订单列表控制器（用户 + 服务商双角色）
class OrderListController extends GetxController {
  final _repository = OrderRepository();
  final EasyRefreshController refreshController = EasyRefreshController(
      controlFinishRefresh: true, controlFinishLoad: true);

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedTab = 0.obs;
  final RxInt currentPage = 1.obs;

  static const pageSize = 10;
  bool _noMore = false;
  bool get hasMore => !_noMore;

  bool get isProvider {
    final user = AuthService.instance.userRx.value;
    return user?.roleId == AppConfig.MERCHANT_USER_TYPE;
  }

  static final _providerTabs = ['全部', '待接单', '进行中', '已完成'];
  static final _customerTabs = ['全部', '待支付', '待服务', '服务中', '已完成'];

  List<String> get tabs => isProvider ? _providerTabs : _customerTabs;

  /// Tab → 对应状态列表（null = 全部）
  /// 待支付: pending
  /// 待服务: paid + accepted + en_route（已支付/已接单/已出发，等待服务开始）
  /// 服务中: in_progress
  /// 已完成: completed
  List<String>? get _filterStatuses {
    final t = selectedTab.value;
    if (isProvider) {
      switch (t) {
        case 1: return ['pending'];
        case 2: return ['in_progress'];
        case 3: return ['completed'];
        default: return null;
      }
    }
    switch (t) {
      case 1: return ['pending'];
      case 2: return ['paid', 'accepted', 'en_route'];
      case 3: return ['in_progress'];
      case 4: return ['completed'];
      default: return null;
    }
  }

  /// 获取 API 调用的 status 参数（单个状态）
  String? get _filterStatus {
    final list = _filterStatuses;
    return list != null && list.length == 1 ? list.first : null;
  }

  /// 获取 API 调用的 statuses 参数（多状态，逗号分隔）
  String? get _filterStatusesParam {
    final list = _filterStatuses;
    return list != null && list.length > 1 ? list.join(',') : null;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is int) selectedTab.value = args.clamp(0, 4);
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
      final response = isProvider
          ? await _repository.getProviderOrders(
              status: _filterStatus,
              statuses: _filterStatusesParam,
              pageIndex: 1, pageSize: pageSize)
          : await _repository.getOrderList(
              status: _filterStatus,
              statuses: _filterStatusesParam,
              pageIndex: 1, pageSize: pageSize);
      if (response.isSuccess && response.data != null) {
        orders.value = response.data!;
        _noMore = response.data!.length < pageSize;
      }
    } catch (e) {
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
      final response = isProvider
          ? await _repository.getProviderOrders(
              status: _filterStatus,
              statuses: _filterStatusesParam,
              pageIndex: currentPage.value,
              pageSize: pageSize)
          : await _repository.getOrderList(
              status: _filterStatus,
              statuses: _filterStatusesParam,
              pageIndex: currentPage.value,
              pageSize: pageSize);
      if (response.isSuccess && response.data != null) {
        final d = response.data!;
        orders.addAll(d);
        _noMore = d.length < pageSize;
      }
      refreshController.finishLoad(
          hasMore ? IndicatorResult.success : IndicatorResult.noMore);
    } catch (e) {
      currentPage.value--;
      refreshController.finishLoad(IndicatorResult.fail);
    }
  }

  // ═══ 服务商操作 ═══

  Future<void> _providerAction(
      Future<dynamic> Function() fn, String successMsg, String errorMsg) async {
    LoadingUtil.show();
    try {
      await fn();
      ToastUtil.showSuccess(successMsg);
      onRefresh();
    } catch (e) {
      ToastUtil.showError('$errorMsg: $e');
    } finally {
      LoadingUtil.dismiss();
    }
  }

  Future<void> acceptOrder(int id) =>
      _providerAction(() => _repository.acceptOrder(id), '已接单', '接单失败');

  Future<void> rejectOrder(int id) =>
      _providerAction(() => _repository.rejectOrder(id), '已拒单', '拒单失败');

  Future<void> enRouteOrder(int id) =>
      _providerAction(() => _repository.enRouteOrder(id), '已出发', '操作失败');

  Future<void> startService(int id) =>
      _providerAction(() => _repository.startService(id), '服务已开始', '操作失败');

  Future<void> completeService(int id) =>
      _providerAction(() => _repository.completeService(id), '服务已完成', '操作失败');

  Future<void> cancelOrder(int id) =>
      _providerAction(() => _repository.cancelOrder(id), '已取消', '取消失败');

  // ═══ 用户操作 ═══

  Future<void> requestRefund(int orderId, String reason) async {
    LoadingUtil.show();
    try {
      await _repository.requestRefund(orderId, reason);
      ToastUtil.showSuccess('退款申请已提交，请等待审核');
      onRefresh();
    } catch (e) {
      ToastUtil.showError('提交失败：$e');
    } finally {
      LoadingUtil.dismiss();
    }
  }
}
