/// 地址数据模型
///
/// 用于存储和管理用户地址信息，包括收货人、联系方式、详细地址等
class AddressModel {
  /// 地址唯一标识
  final int id;

  /// 完整地址名称
  final String name;

  /// 简短显示名称（用于列表展示）
  final String shortName;

  /// 省份
  final String province;

  /// 城市
  final String city;

  /// 区县
  final String district;

  /// 街道/详细地址
  final String street;

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 是否为默认地址
  final bool isDefault;

  /// 收货人姓名
  final String? contactName;

  /// 联系电话
  final String? contactPhone;

  AddressModel({
    this.id = 0,
    required this.name,
    required this.shortName,
    required this.province,
    required this.city,
    required this.district,
    required this.street,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    this.contactName,
    this.contactPhone,
  });

  /// 从 JSON 创建 AddressModel 实例
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      shortName: json['shortName'] as String? ?? '',
      province: json['province'] as String? ?? '',
      city: json['city'] as String? ?? '',
      district: json['district'] as String? ?? '',
      street: json['street'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isDefault: json['isDefault'] as bool? ?? false,
      contactName: json['contactName'] as String?,
      contactPhone: json['contactPhone'] as String?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'province': province,
      'city': city,
      'district': district,
      'street': street,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      'contactName': contactName,
      'contactPhone': contactPhone,
    };
  }

  /// 创建副本并修改部分字段
  AddressModel copyWith({
    int? id,
    String? name,
    String? shortName,
    String? province,
    String? city,
    String? district,
    String? street,
    double? latitude,
    double? longitude,
    bool? isDefault,
    String? contactName,
    String? contactPhone,
  }) {
    return AddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      province: province ?? this.province,
      city: city ?? this.city,
      district: district ?? this.district,
      street: street ?? this.street,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
    );
  }
}
