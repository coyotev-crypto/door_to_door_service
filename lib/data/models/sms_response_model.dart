class SmsResponseModel {
  final int code;
  final String? message;

  SmsResponseModel({
    required this.code,
    this.message,
  });

  factory SmsResponseModel.fromJson(Map<String, dynamic> json) {
    return SmsResponseModel(
      code: json['code'] as int? ?? -1,
      message: json['msg']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': message,
    };
  }

  bool get isSuccess => code == 200;

  SmsResponseModel copyWith({
    int? code,
    String? message,
  }) {
    return SmsResponseModel(
      code: code ?? this.code,
      message: message ?? this.message,
    );
  }
}
