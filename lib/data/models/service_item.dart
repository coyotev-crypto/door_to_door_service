/// 服务项模型
class ServiceItem {
  final int id;
  final String name;
  final double rating;
  final double price;
  final double? originalPrice;
  final bool isNew;
  final String? providerName;
  final String? distance;
  final bool? isFavorite;
  final int? orderCount;
  final double? travelFee;
  final int? favoriteCount;

  ServiceItem({
    required this.id,
    required this.name,
    required this.rating,
    required this.price,
    this.originalPrice,
    this.isNew = false,
    this.providerName,
    this.distance,
    this.isFavorite,
    this.orderCount,
    this.travelFee,
    this.favoriteCount,
  });

  /// 获取距离的数值（用于排序）
  double get distanceValue {
    if (distance == null || distance!.isEmpty) return double.infinity;
    try {
      return double.parse(distance!);
    } catch (e) {
      return double.infinity;
    }
  }

  /// 从JSON创建实例
  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      isNew: json['isNew'] as bool? ?? false,
      providerName: json['providerName'] as String?,
      distance: json['distance'] as String?,
      isFavorite: json['isFavorite'] as bool?,
      orderCount: json['orderCount'] as int?,
      travelFee: (json['travelFee'] as num?)?.toDouble(),
      favoriteCount: json['favoriteCount'] as int?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'price': price,
      'originalPrice': originalPrice,
      'isNew': isNew,
      'providerName': providerName,
      'distance': distance,
      'isFavorite': isFavorite,
      'orderCount': orderCount,
      'travelFee': travelFee,
      'favoriteCount': favoriteCount,
    };
  }

  /// 创建副本并修改部分字段
  ServiceItem copyWith({
    int? id,
    String? name,
    double? rating,
    double? price,
    double? originalPrice,
    bool? isNew,
    String? providerName,
    String? distance,
    bool? isFavorite,
    int? orderCount,
    double? travelFee,
    int? favoriteCount,
  }) {
    return ServiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      isNew: isNew ?? this.isNew,
      providerName: providerName ?? this.providerName,
      distance: distance ?? this.distance,
      isFavorite: isFavorite ?? this.isFavorite,
      orderCount: orderCount ?? this.orderCount,
      travelFee: travelFee ?? this.travelFee,
      favoriteCount: favoriteCount ?? this.favoriteCount,
    );
  }
}
