import 'package:door_to_door_service/core/config/app_config.dart';
import 'package:door_to_door_service/core/services/auth_service.dart';
import 'package:door_to_door_service/core/utils/toast_util.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

/// 订单详情控制器
class OrderDetailController extends GetxController {
  final OrderRepository _orderRepository = OrderRepository();

  final Rxn<OrderModel> _order = Rxn<OrderModel>();
  final RxBool _isLoading = false.obs;

  OrderModel? get order => _order.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _loadOrderDetail();
  }

  /// 加载订单详情
  Future<void> _loadOrderDetail() async {
    try {
      _isLoading.value = true;
      final orderId = Get.parameters['id'];
      if (orderId == null) {
        ToastUtil.showError('订单ID不存在');
        Get.back();
        return;
      }

      // 调用API获取订单详情
      final id = int.parse(orderId);
      final isProvider =
          AuthService.instance.user?.roleId == AppConfig.MERCHANT_USER_TYPE;
      final response = isProvider
          ? await _orderRepository.getProviderOrderDetail(id)
          : await _orderRepository.getOrderDetail(id);
      if (response.isSuccess && response.data != null) {
        _order.value = response.data;
      } else {
        ToastUtil.showError(response.message);
        Get.back();
      }
    } catch (e) {
      ToastUtil.showError('加载订单失败: $e');
      Get.back();
    } finally {
      _isLoading.value = false;
    }
  }

  /// 复制核销码
  Future<void> copyVerificationCode(String code) async {
    try {
      await Clipboard.setData(ClipboardData(text: code));
      ToastUtil.showSuccess('已复制到剪贴板');
    } catch (e) {
      ToastUtil.showError('复制失败');
    }
  }

  /// 拨打服务人员电话
  void callProvider(String phone) {
    if (phone.isEmpty) {
      ToastUtil.showError('暂无服务人员电话');
      return;
    }
    // 实现拨号逻辑
    // url_launcher 可用于实现，示例:
    // launchUrl(Uri(scheme: 'tel', path: phone));
    ToastUtil.showMessage('拨打 $phone');
  }

  /// 联系客服
  void contactService() {
    ToastUtil.showMessage('正在打开客服...');
    // 实现联系客服逻辑
  }

  /// 分享订单
  void shareOrder(OrderModel order) {
    // 实现分享逻辑
    // share_plus 包可用于实现
    ToastUtil.showMessage('分享订单功能即将推出');
  }

  /// 刷新订单信息
  Future<void> refreshOrderDetail() async {
    await _loadOrderDetail();
  }
}





