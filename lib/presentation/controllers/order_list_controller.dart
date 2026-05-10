import 'package:get/get.dart';
import '../../core/utils/log_util.dart';
import '../../core/utils/toast_util.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

/// 订单列表控制器（服务商视角）
class OrderListController extends GetxController {
  final String _tag = 'OrderListController';
  final OrderRepository _repository = OrderRepository();

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    try {
      final response = await _repository.getOrderList();
      if (response.isSuccess && response.data != null) {
        orders.value = response.data!;
      }
    } catch (e) {
      LogUtil.e('加载订单列表失败: $e', tag: _tag);
      ToastUtil.showError('加载订单失败');
    } finally {
      isLoading.value = false;
    }
  }
}
