import 'package:door_to_door_service/core/config/app_config.dart';
import 'package:door_to_door_service/core/network/api_endpoints.dart';
import 'package:door_to_door_service/core/services/token_service.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/utils/log_util.dart';
import '../../core/utils/toast_util.dart';
import '../../routes/route_names.dart';

/// 支付控制器
///
/// 流程：
///   1. 获取 token，通过 WebViewCookieManager 预写入 Admin-Token 和 token cookie
///   2. loadRequest 加载支付页（同时传 Authorization header）
///   3. onPageFinished 时隐藏 loading（仅首次，忽略 SPA 内部导航的后续回调）
///   4. 监听支付结果 URL，成功/失败后导航到对应页面
class PaymentController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxBool isWebViewReady = false.obs;

  late final int orderId;
  late final String orderNo;
  late final String paymentUrl;
  late final String _cookieDomain;
  late final WebViewController webViewController;

  String? _token;
  int _retryCount = 0;
  static const int _maxRetries = 2;
  bool _pageFinished = false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    orderId = args['orderId'] as int;
    orderNo = args['orderNo'] as String;
    paymentUrl = '${AppConfig.webUrl}${ApiEndpoints.payment}$orderNo';
    _cookieDomain = Uri.parse(AppConfig.webUrl).host;

    LogUtil.d('=== PaymentController.onInit ===', tag: 'PAYMENT');
    LogUtil.d('orderId: $orderId, orderNo: $orderNo', tag: 'PAYMENT');
    LogUtil.d('paymentUrl: $paymentUrl', tag: 'PAYMENT');
    LogUtil.d('cookieDomain: $_cookieDomain', tag: 'PAYMENT');

    // 同步创建 WebViewController，确保原生视图尽早初始化
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(_buildNavigationDelegate())
      ..addJavaScriptChannel('FlutterConsole',
          onMessageReceived: (JavaScriptMessage msg) {
        LogUtil.d('[JS Console] ${msg.message}', tag: 'PAYMENT');
      });
    isWebViewReady.value = true;

    // 异步：获取 token → 设置 cookie → 加载页面
    _loadPaymentPage();
  }

  NavigationDelegate _buildNavigationDelegate() {
    return NavigationDelegate(
      onPageStarted: (url) {
        LogUtil.d('onPageStarted: $url', tag: 'PAYMENT');
      },
      onPageFinished: (url) {
        LogUtil.d('onPageFinished: $url', tag: 'PAYMENT');

        // CookieManager 和 Authorization header 已在 loadRequest 前设置，
        // 无需 JS 注入 + reload，避免页面重复加载
        if (!_pageFinished) {
          _pageFinished = true;
          isLoading.value = false;
        }
      },
      onWebResourceError: (error) {
        LogUtil.e(
          'onWebResourceError: code=${error.errorType}, '
          'desc=${error.description}, '
          'url=${error.url}, '
          'isForMainFrame=${error.isForMainFrame}',
          tag: 'PAYMENT',
        );
        if (error.isForMainFrame != true) return;
        isLoading.value = false;
        _handleMainFrameError(error.errorCode, error.description);
      },
      onNavigationRequest: (request) {
        final url = request.url;
        LogUtil.d('onNavigationRequest: $url', tag: 'PAYMENT');

        if (url.contains('/payment/success')) {
          ToastUtil.showSuccess('支付成功');
          Get.until(
            (route) => route.settings.name == RouteNames.home,
          );
          return NavigationDecision.prevent;
        }
        if (url.contains('/payment/fail') ||
            url.contains('/payment/cancel')) {
          ToastUtil.showError('支付失败，请重试');
          Get.back();
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
    );
  }

  Future<void> _loadPaymentPage() async {
    _token = await TokenService.instance.getToken();
    LogUtil.d('token exists: ${_token != null}', tag: 'PAYMENT');

    // 通过 CookieManager 预写入认证 cookie
    if (_token != null && _token!.isNotEmpty) {
      await _setAuthCookies(_token!);
    }

    final ctrl = webViewController;

    // 加载支付页：cookie 已预设 + headers 传 token
    final headers = _token != null && _token!.isNotEmpty
        ? <String, String>{'Authorization': 'Bearer $_token'}
        : <String, String>{};
    LogUtil.d(
        'Loading payment URL (cookies pre-set, headers: ${headers.isNotEmpty})',
        tag: 'PAYMENT');
    await ctrl.loadRequest(Uri.parse(paymentUrl), headers: headers);
  }

  /// 通过 WebViewCookieManager 预设认证 cookie
  Future<void> _setAuthCookies(String token) async {
    final cookieManager = WebViewCookieManager();
    final cookies = [
      WebViewCookie(
        name: 'token',
        value: token,
        domain: _cookieDomain,
        path: '/',
      ),
      WebViewCookie(
        name: 'Admin-Token',
        value: token,
        domain: _cookieDomain,
        path: '/',
      ),
    ];
    try {
      await Future.wait(cookies.map((c) => cookieManager.setCookie(c)));
      LogUtil.d('Auth cookies set for $_cookieDomain', tag: 'PAYMENT');
    } catch (e) {
      LogUtil.e('Failed to set cookies: $e', tag: 'PAYMENT');
    }
  }

  /// 主页面网络错误处理
  void _handleMainFrameError(int errorCode, String description) {
    if (errorCode == -1 || errorCode == -2 || errorCode == -6 || errorCode == -8) {
      if (_retryCount < _maxRetries) {
        _retryCount++;
        final delay = Duration(seconds: 2 * _retryCount);
        LogUtil.d('Retrying ($_retryCount/$_maxRetries) in ${delay.inSeconds}s...', tag: 'PAYMENT');
        Future.delayed(delay, () {
          isLoading.value = true;
          webViewController.loadRequest(Uri.parse(paymentUrl));
        });
        return;
      }
      ToastUtil.showError('服务器连接异常，请检查网络或稍后重试');
      return;
    }
    ToastUtil.showError('页面加载失败: $description');
  }
}
