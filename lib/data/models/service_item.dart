/// 服务项模型
class ServiceItem {
  final int id;
  final int userId;
  final String name;
  final double rating;
  final String price;
  final int? categoryId;
  final String? categoryName;
  final int? status;
  final bool isNew;
  final String? providerName;
  final String? distance;
  final bool? isFavorite;
  final int? orderCount;
  final String? travelFee;
  final int? favoriteCount;
  final double? latitude;
  final double? longitude;
  final String? address;
  final double? deliveryRange;
  final String? avatar;
  final List<Map<String, dynamic>>? timeSlots;
  final List<Map<String, dynamic>>? specialDateSlots;
  final List<Map<String, dynamic>>? prices;
  final int? auditStatus; // 审核状态: 0=待审核, 1=通过, 2=驳回
  final String? auditRemark; // 审核驳回原因

  ServiceItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.rating,
    required this.price,
    this.categoryId,
    this.categoryName,
    this.isNew = false,
    this.providerName,
    this.distance,
    this.isFavorite,
    this.orderCount,
    this.travelFee,
    this.favoriteCount,
    this.status,
    this.latitude,
    this.longitude,
    this.address,
    this.deliveryRange,
    this.avatar,
    this.timeSlots,
    this.specialDateSlots,
    this.prices,
    this.auditStatus,
    this.auditRemark,
  });

  /// 默认展示时长（分钟），从 prices 第一项取
  int get defaultDurationMinutes {
    if (prices != null && prices!.isNotEmpty) {
      final d = prices!.first['durationMinutes'];
      if (d is int) return d;
      if (d is String) return int.tryParse(d) ?? 60;
      return 60;
    }
    return 60;
  }

  /// 价格作为 double（用于数值计算）
  double get priceValue => _parseDecimal(price);

  /// 出行费作为 double（用于数值计算）
  double? get travelFeeValue =>
      travelFee != null ? _parseDecimalNullable(travelFee!) : null;

  /// 获取距离的数值（用于排序）
  double get distanceValue {
    if (distance == null || distance!.isEmpty) return double.infinity;
    try {
      return double.parse(distance!);
    } catch (e) {
      return double.infinity;
    }
  }

  /// 解析 decimal 字符串为 double
  static double _parseDecimal(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static double? _parseDecimalNullable(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) {
      final parsed = double.tryParse(v);
      return parsed;
    }
    return null;
  }

  /// 从JSON解析价格（优先取顶层 price 字段，其次取 prices[0].price）
  static String _priceFromJson(Map<String, dynamic> json) {
    final topPrice = json['price'];
    if (topPrice != null) {
      final s = topPrice.toString();
      final p = double.tryParse(s);
      if (p != null && p > 0) return s;
    }
    final prices = json['prices'] as List<dynamic>?;
    if (prices != null && prices.isNotEmpty) {
      final first = prices.first as Map<String, dynamic>;
      final p = first['price'];
      if (p != null) return p.toString();
    }
    return '0';
  }

  static int? _parseAuditStatus(dynamic v) {
    if (v is int) return v;
    if (v is String) {
      return switch (v) {
        'pending' => 0,
        'approved' => 1,
        'rejected' => 2,
        _ => int.tryParse(v),
      };
    }
    return null;
  }

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      price: _priceFromJson(json),
      categoryId: json['categoryId'] is String
          ? int.tryParse(json['categoryId'] as String)
          : json['categoryId'] as int?,
      categoryName: json['categoryName'] as String?,
      isNew: json['isNew'] as bool? ?? false,
      providerName: json['providerName'] as String?,
      distance: json['distance'] as String?,
      isFavorite: json['isFavorite'] as bool?,
      orderCount: json['orderCount'] as int?,
      travelFee: json['travelFee']?.toString(),
      favoriteCount: json['favoriteCount'] as int?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      deliveryRange: (json['deliveryRange'] as num?)?.toDouble(),
      avatar: json['avatar'] as String?,
      timeSlots: (json['timeSlots'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      specialDateSlots: (json['specialDateSlots'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      prices: (json['prices'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      status: json['status'] is String
          ? int.tryParse(json['status'] as String)
          : json['status'] as int?,
      auditStatus: _parseAuditStatus(json['auditStatus']),
      auditRemark: json['auditRemark'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'rating': rating,
      'price': price,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'isNew': isNew,
      'providerName': providerName,
      'distance': distance,
      'isFavorite': isFavorite,
      'orderCount': orderCount,
      'travelFee': travelFee,
      'favoriteCount': favoriteCount,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'deliveryRange': deliveryRange,
      'avatar': avatar,
      'status': status,
      'auditStatus': auditStatus,
      'auditRemark': auditRemark,
    };
  }

  /// 创建副本并修改部分字段
  ServiceItem copyWith({
    int? id,
    int? userId,
    String? name,
    double? rating,
    String? price,
    int? categoryId,
    String? categoryName,
    bool? isNew,
    String? providerName,
    String? distance,
    bool? isFavorite,
    int? orderCount,
    String? travelFee,
    int? favoriteCount,
    int? status,
    double? latitude,
    double? longitude,
    String? address,
    double? deliveryRange,
    String? avatar,
    int? auditStatus,
    String? auditRemark,
  }) {
    return ServiceItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isNew: isNew ?? this.isNew,
      providerName: providerName ?? this.providerName,
      distance: distance ?? this.distance,
      isFavorite: isFavorite ?? this.isFavorite,
      orderCount: orderCount ?? this.orderCount,
      travelFee: travelFee ?? this.travelFee,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      deliveryRange: deliveryRange ?? this.deliveryRange,
      avatar: avatar ?? this.avatar,
      auditStatus: auditStatus ?? this.auditStatus,
      auditRemark: auditRemark ?? this.auditRemark,
    );
  }

  /// 是否审核驳回
  bool get isAuditRejected => auditStatus == 2;

  /// 审核状态文本
  String get auditStatusText {
    switch (auditStatus) {
      case 0:
        return '待审核';
      case 1:
        return '已通过';
      case 2:
        return '已驳回';
      default:
        return '';
    }
  }
}
