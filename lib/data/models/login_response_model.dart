import 'user_model.dart';

class LoginResponseModel {
  final int code;
  final String? token;
  final String? currentAuthority;
  final String? expire;
  final bool? success;
  final String? message;

  LoginResponseModel({
    required this.code,
    this.token,
    this.currentAuthority,
    this.expire,
    this.success,
    this.message,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      code: json['code'] as int? ?? -1,
      token: json['token']?.toString(),
      currentAuthority: json['currentAuthority']?.toString(),
      expire: json['expire']?.toString(),
      success: json['success'] as bool?,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'token': token,
      'currentAuthority': currentAuthority,
      'expire': expire,
      'success': success,
      'message': message,
    };
  }

  bool get isSuccess => code == 200 && success == true;

  LoginResponseModel copyWith({
    int? code,
    String? token,
    String? currentAuthority,
    String? expire,
    bool? success,
    String? message,
  }) {
    return LoginResponseModel(
      code: code ?? this.code,
      token: token ?? this.token,
      currentAuthority: currentAuthority ?? this.currentAuthority,
      expire: expire ?? this.expire,
      success: success ?? this.success,
      message: message ?? this.message,
    );
  }
}
