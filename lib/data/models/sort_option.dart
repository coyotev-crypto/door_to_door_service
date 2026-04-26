/// 服务排序选项枚举
enum ServiceSortOption {
  /// 综合排序
  comprehensive,
  /// 距离排序
  distance,
  /// 价格排序
  price,
  /// 销量排序
  sales,
  /// 评分排序
  rating,
}

/// 排序选项扩展
extension ServiceSortOptionExtension on ServiceSortOption {
  /// 获取排序选项名称
  String get displayName {
    switch (this) {
      case ServiceSortOption.comprehensive:
        return '综合';
      case ServiceSortOption.distance:
        return '距离';
      case ServiceSortOption.price:
        return '价格';
      case ServiceSortOption.sales:
        return '销量';
      case ServiceSortOption.rating:
        return '评分';
    }
  }

  /// 获取排序选项图标
  String get icon {
    switch (this) {
      case ServiceSortOption.comprehensive:
        return 'assets/icons/sort_comprehensive.png';
      case ServiceSortOption.distance:
        return 'assets/icons/sort_distance.png';
      case ServiceSortOption.price:
        return 'assets/icons/sort_price.png';
      case ServiceSortOption.sales:
        return 'assets/icons/sort_sales.png';
      case ServiceSortOption.rating:
        return 'assets/icons/sort_rating.png';
    }
  }

  /// 从字符串获取排序选项
  static ServiceSortOption fromString(String value) {
    switch (value) {
      case 'distance':
        return ServiceSortOption.distance;
      case 'price':
        return ServiceSortOption.price;
      case 'sales':
        return ServiceSortOption.sales;
      case 'rating':
        return ServiceSortOption.rating;
      default:
        return ServiceSortOption.comprehensive;
    }
  }

  /// 转换为字符串
  String toValue() {
    switch (this) {
      case ServiceSortOption.comprehensive:
        return 'comprehensive';
      case ServiceSortOption.distance:
        return 'distance';
      case ServiceSortOption.price:
        return 'price';
      case ServiceSortOption.sales:
        return 'sales';
      case ServiceSortOption.rating:
        return 'rating';
    }
  }
}
