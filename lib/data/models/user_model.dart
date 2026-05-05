class UserModel {
  final String id;
  final String phoneNumber;
  final String? nickname;
  final String? avatar;
  final String? email;
  final String? gender; // 性别：0-未知，1-男，2-女
  final String? remark; // 备注
  final bool? hasPaymentPassword; // 是否已设置支付密码
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.phoneNumber,
    this.nickname,
    this.avatar,
    this.email,
    this.gender,
    this.remark,
    this.hasPaymentPassword,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      nickname: json['nickname']?.toString(),
      avatar: json['avatar']?.toString(),
      email: json['email']?.toString(),
      gender: json['gender']?.toString(),
      remark: json['remark']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'nickname': nickname,
      'avatar': avatar,
      'email': email,
      'gender': gender,
      'remark': remark,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? nickname,
    String? avatar,
    String? email,
    String? gender,
    String? remark,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      remark: remark ?? this.remark,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
