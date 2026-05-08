/// 服务商资质认证模型
/// 用于存储和解析服务商资质认证信息
class ProviderQualificationModel {
  /// 年龄
  final int? age;

  /// 审核人ID
  final int? auditBy;

  /// 审核备注
  final String? auditRemark;

  /// 审核状态
  final String? auditStatus;

  /// 审核时间
  final String? auditTime;

  /// 证书等级
  final String? certificateLevel;

  /// 创建人ID
  final int? createBy;

  /// 创建时间
  final String? createdAt;

  /// 紧急联系人
  final String? emergencyContact;

  /// 紧急联系人电话
  final String? emergencyPhone;

  /// 性别
  final String? gender;

  /// 健康证URL
  final String? healthCert;

  /// ID
  final int? id;

  /// 身份证反面URL
  final String? idCardBack;

  /// 身份证正面URL
  final String? idCardFront;

  /// 姓名
  final String? name;

  /// 无犯罪记录证明URL
  final String? noCriminalRecord;

  /// 其他证书URL
  final String? otherCert;

  /// 电话
  final String? phone;

  /// 从业证明URL
  final String? qualificationCert;

  /// 本人近期照URL
  final String? recentPhoto;

  /// 更新人ID
  final int? updateBy;

  /// 更新时间
  final String? updatedAt;

  /// 用户ID
  final int? userId;

  ProviderQualificationModel({
    this.age,
    this.auditBy,
    this.auditRemark,
    this.auditStatus,
    this.auditTime,
    this.certificateLevel,
    this.createBy,
    this.createdAt,
    this.emergencyContact,
    this.emergencyPhone,
    this.gender,
    this.healthCert,
    this.id,
    this.idCardBack,
    this.idCardFront,
    this.name,
    this.noCriminalRecord,
    this.otherCert,
    this.phone,
    this.qualificationCert,
    this.recentPhoto,
    this.updateBy,
    this.updatedAt,
    this.userId,
  });

  /// 从JSON创建实例
  factory ProviderQualificationModel.fromJson(Map<String, dynamic> json) {
    return ProviderQualificationModel(
      age: json['age'] as int?,
      auditBy: json['auditBy'] as int?,
      auditRemark: json['auditRemark']?.toString(),
      auditStatus: json['auditStatus']?.toString(),
      auditTime: json['auditTime']?.toString(),
      certificateLevel: json['certificateLevel']?.toString(),
      createBy: json['createBy'] as int?,
      createdAt: json['createdAt']?.toString(),
      emergencyContact: json['emergencyContact']?.toString(),
      emergencyPhone: json['emergencyPhone']?.toString(),
      gender: json['gender']?.toString(),
      healthCert: json['healthCert']?.toString(),
      id: json['id'] as int?,
      idCardBack: json['idCardBack']?.toString(),
      idCardFront: json['idCardFront']?.toString(),
      name: json['name']?.toString(),
      noCriminalRecord: json['noCriminalRecord']?.toString(),
      otherCert: json['otherCert']?.toString(),
      phone: json['phone']?.toString(),
      qualificationCert: json['qualificationCert']?.toString(),
      recentPhoto: json['recentPhoto']?.toString(),
      updateBy: json['updateBy'] as int?,
      updatedAt: json['updatedAt']?.toString(),
      userId: json['userId'] as int?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'auditBy': auditBy,
      'auditRemark': auditRemark,
      'auditStatus': auditStatus,
      'auditTime': auditTime,
      'certificateLevel': certificateLevel,
      'createBy': createBy,
      'createdAt': createdAt,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'gender': gender,
      'healthCert': healthCert,
      'id': id,
      'idCardBack': idCardBack,
      'idCardFront': idCardFront,
      'name': name,
      'noCriminalRecord': noCriminalRecord,
      'otherCert': otherCert,
      'phone': phone,
      'qualificationCert': qualificationCert,
      'recentPhoto': recentPhoto,
      'updateBy': updateBy,
      'updatedAt': updatedAt,
      'userId': userId,
    };
  }

  /// 复制并修改部分属性
  ProviderQualificationModel copyWith({
    int? age,
    int? auditBy,
    String? auditRemark,
    String? auditStatus,
    String? auditTime,
    String? certificateLevel,
    int? createBy,
    String? createdAt,
    String? emergencyContact,
    String? emergencyPhone,
    String? gender,
    String? healthCert,
    int? id,
    String? idCardBack,
    String? idCardFront,
    String? name,
    String? noCriminalRecord,
    String? otherCert,
    String? phone,
    String? qualificationCert,
    String? recentPhoto,
    int? updateBy,
    String? updatedAt,
    int? userId,
  }) {
    return ProviderQualificationModel(
      age: age ?? this.age,
      auditBy: auditBy ?? this.auditBy,
      auditRemark: auditRemark ?? this.auditRemark,
      auditStatus: auditStatus ?? this.auditStatus,
      auditTime: auditTime ?? this.auditTime,
      certificateLevel: certificateLevel ?? this.certificateLevel,
      createBy: createBy ?? this.createBy,
      createdAt: createdAt ?? this.createdAt,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      gender: gender ?? this.gender,
      healthCert: healthCert ?? this.healthCert,
      id: id ?? this.id,
      idCardBack: idCardBack ?? this.idCardBack,
      idCardFront: idCardFront ?? this.idCardFront,
      name: name ?? this.name,
      noCriminalRecord: noCriminalRecord ?? this.noCriminalRecord,
      otherCert: otherCert ?? this.otherCert,
      phone: phone ?? this.phone,
      qualificationCert: qualificationCert ?? this.qualificationCert,
      recentPhoto: recentPhoto ?? this.recentPhoto,
      updateBy: updateBy ?? this.updateBy,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }
}
