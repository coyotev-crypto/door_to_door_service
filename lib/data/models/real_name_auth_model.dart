
class RealNameAuthModel {
  final String? realName; // 真实姓名
  final String? idCardNumber; // 身份证号
  final String? realNameAuthStatus; // 实名认证状态：0-未认证，1-已认证
  final String? idCardFrontImageUrl; // 身份证正面图片
  final String? idCardBackImageUrl; // 身份证反面图片

  RealNameAuthModel({
    this.realName,
    this.idCardNumber,
    this.realNameAuthStatus,
    this.idCardFrontImageUrl,
    this.idCardBackImageUrl,
  });

  factory RealNameAuthModel.fromJson(Map<String, dynamic> json) {
    return RealNameAuthModel(
      realName: json['realName']?.toString(),
      idCardNumber: json['idCardNumber']?.toString(),
      realNameAuthStatus: json['realNameAuthStatus']?.toString(),
      idCardFrontImageUrl: json['idCardFrontImageUrl']?.toString(),
      idCardBackImageUrl: json['idCardBackImageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'realName': realName,
      'idCardNumber': idCardNumber,
      'realNameAuthStatus': realNameAuthStatus,
      'idCardFrontImageUrl': idCardFrontImageUrl,
      'idCardBackImageUrl': idCardBackImageUrl,
    };
  }

  RealNameAuthModel copyWith({
    String? realName,
    String? idCardNumber,
    String? realNameAuthStatus,
    String? idCardFrontImageUrl,
    String? idCardBackImageUrl,
  }) {
    return RealNameAuthModel(
      realName: realName ?? this.realName,
      idCardNumber: idCardNumber ?? this.idCardNumber,
      realNameAuthStatus: realNameAuthStatus ?? this.realNameAuthStatus,
      idCardFrontImageUrl: idCardFrontImageUrl ?? this.idCardFrontImageUrl,
      idCardBackImageUrl: idCardBackImageUrl ?? this.idCardBackImageUrl,
    );
  }
}
