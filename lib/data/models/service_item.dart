/// 服务项模型
class ServiceItem {
  final int id;
  final String name;
  final double rating;
  final double price;
  final int? categoryId;
  final String? categoryName;
  final int? status;
  final double? originalPrice;
  final bool isNew;
  final String? providerName;
  final String? distance;
  final bool? isFavorite;
  final int? orderCount;
  final double? travelFee;
  final int? favoriteCount;
  final double? latitude;
  final double? longitude;
  final String? address;
  final double? deliveryRange;

  ServiceItem({
    required this.id,
    required this.name,
    required this.rating,
    required this.price,
    this.categoryId,
    this.categoryName,
    this.originalPrice,
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
      categoryId: json['categoryId'] is String
          ? int.tryParse(json['categoryId'] as String)
          : json['categoryId'] as int?,
      categoryName: json['categoryName'] as String?,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      isNew: json['isNew'] as bool? ?? false,
      providerName: json['providerName'] as String?,
      distance: json['distance'] as String?,
      isFavorite: json['isFavorite'] as bool?,
      orderCount: json['orderCount'] as int?,
      travelFee: (json['travelFee'] as num?)?.toDouble(),
      favoriteCount: json['favoriteCount'] as int?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      deliveryRange: (json['deliveryRange'] as num?)?.toDouble(),
      status: json['status'] is String
          ? int.tryParse(json['status'] as String)
          : json['status'] as int?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'price': price,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'originalPrice': originalPrice,
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
      'status': status,
    };
  }

  /// 创建副本并修改部分字段
  ServiceItem copyWith({
    int? id,
    String? name,
    double? rating,
    double? price,
    double? originalPrice,
    int? categoryId,
    String? categoryName,
    bool? isNew,
    String? providerName,
    String? distance,
    bool? isFavorite,
    int? orderCount,
    double? travelFee,
    int? favoriteCount,
    int? status,
    double? latitude,
    double? longitude,
    String? address,
    double? deliveryRange,
  }) {
    return ServiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      originalPrice: originalPrice ?? this.originalPrice,
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
    );
  }
}
