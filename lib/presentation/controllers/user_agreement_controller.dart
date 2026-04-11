import 'package:flutter/material.dart';
import '../../data/repositories/agreement_repository.dart';
import '../../data/models/agreement_model.dart';

class UserAgreementController extends ChangeNotifier {
  final AgreementRepository _agreementRepository = AgreementRepository();

  // 用户协议内容
  String get agreementContent => _agreement?.content ?? '';

  // 协议模型
  AgreementModel? _agreement;

  // 是否正在加载
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 错误信息
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// 加载用户协议
  Future<void> loadUserAgreement({String? version}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _agreement = await _agreementRepository.getUserAgreement(version: version);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      // 如果加载失败，使用默认内容
      _agreement = AgreementModel(
        id: 0,
        type: 'user',
        version: '1.0.0',
        title: '用户协议',
        content: getDefaultAgreementContent(),
        isCurrent: true,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取默认用户协议内容
  String getDefaultAgreementContent() {
    return "1. 服务条款的确认和接纳\n欢迎使用上门服务应用。在使用本应用之前，请您仔细阅读本用户协议。\n如果您不同意本用户协议的任何条款，请勿使用本应用。\n\n2. 服务说明\n本应用提供上门服务平台，连接用户与服务者。\n用户可以通过本应用预约各种上门服务，服务者可以通过本平台提供服务。\n\n3. 用户账号\n3.1 用户注册时必须提供真实、准确、完整的个人资料。\n3.2 用户有责任维护账号安全，并对使用该账号的所有活动负责。\n3.3 用户不得将账号转让或出借给他人使用。\n\n4. 服务订单\n4.1 用户通过本应用预约服务时，应确保提供的信息真实准确。\n4.2 用户应按照约定时间接受服务，如需变更应提前通知。\n4.3 服务完成后，用户应及时支付服务费用。\n\n5. 隐私保护\n5.1 本应用重视用户隐私保护，将按照本隐私政策收集、使用、存储用户信息。\n5.2 未经用户同意，不会向任何第三方披露用户个人信息。\n\n6. 免责条款\n6.1 本应用不对服务者的服务质量负责。\n6.2 因不可抗力导致的服务中断，本应用不承担责任。\n6.3 用户使用本应用所产生的一切风险由用户自行承担。\n\n7. 协议修改\n本应用有权根据需要修改本协议条款，修改后的协议一旦公布即代替原协议。\n\n8. 争议解决\n如发生争议，双方应友好协商解决，协商不成的可向有管辖权的人民法院提起诉讼。\n\n本协议自发布之日起生效。";
  }
}
