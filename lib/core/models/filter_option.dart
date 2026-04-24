/// 服务筛选选项模型
class ServiceFilterOption {
  /// 价格区间
  PriceRangeFilter priceRange;

  /// 服务时间
  ServiceTimeFilter serviceTime;

  /// 评分筛选
  RatingFilter rating;

  /// 服务者等级
  ProviderLevelFilter providerLevel;

  /// 服务标签
  List<String> selectedTags;

  ServiceFilterOption({
    PriceRangeFilter? priceRange,
    ServiceTimeFilter? serviceTime,
    RatingFilter? rating,
    ProviderLevelFilter? providerLevel,
    List<String>? selectedTags,
  }) : priceRange = priceRange ?? PriceRangeFilter(),
       serviceTime = serviceTime ?? ServiceTimeFilter(),
       rating = rating ?? RatingFilter(),
       providerLevel = providerLevel ?? ProviderLevelFilter(),
       selectedTags = selectedTags ?? [];

  /// 复制筛选选项
  ServiceFilterOption copyWith({
    PriceRangeFilter? priceRange,
    ServiceTimeFilter? serviceTime,
    RatingFilter? rating,
    ProviderLevelFilter? providerLevel,
    List<String>? selectedTags,
  }) {
    return ServiceFilterOption(
      priceRange: priceRange ?? this.priceRange,
      serviceTime: serviceTime ?? this.serviceTime,
      rating: rating ?? this.rating,
      providerLevel: providerLevel ?? this.providerLevel,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }

  /// 检查是否有任何筛选条件被应用
  bool get hasAnyFilter {
    return priceRange.enabled || 
           serviceTime.enabled || 
           rating.enabled || 
           providerLevel.enabled ||
           selectedTags.isNotEmpty;
  }

  /// 重置所有筛选条件
  void reset() {
    priceRange.reset();
    serviceTime.reset();
    rating.reset();
    providerLevel.reset();
    selectedTags.clear();
  }
}

/// 价格区间筛选
class PriceRangeFilter {
  /// 是否启用
  bool enabled;

  /// 最低价格
  double minPrice;

  /// 最高价格
  double maxPrice;

  PriceRangeFilter({
    this.enabled = false,
    this.minPrice = 0,
    this.maxPrice = 1000,
  });

  /// 重置筛选条件
  void reset() {
    enabled = false;
    minPrice = 0;
    maxPrice = 1000;
  }
}

/// 服务时间筛选
class ServiceTimeFilter {
  /// 是否启用
  bool enabled;

  /// 可用时间段
  List<TimeSlot> availableTimeSlots;

  ServiceTimeFilter({
    this.enabled = false,
    List<TimeSlot>? availableTimeSlots,
  }) : availableTimeSlots = availableTimeSlots ?? [];

  /// 重置筛选条件
  void reset() {
    enabled = false;
    for (var slot in availableTimeSlots) {
      slot.selected = false;
    }
  }
}

/// 时间段
class TimeSlot {
  /// 时间段名称
  final String name;

  /// 开始时间（小时）
  final int startHour;

  /// 结束时间（小时）
  final int endHour;

  /// 是否被选中
  bool selected;

  TimeSlot({
    required this.name,
    required this.startHour,
    required this.endHour,
    this.selected = false,
  });
}

/// 评分筛选
class RatingFilter {
  /// 是否启用
  bool enabled;

  /// 最低评分
  double minRating;

  RatingFilter({
    this.enabled = false,
    this.minRating = 4.0,
  });

  /// 重置筛选条件
  void reset() {
    enabled = false;
    minRating = 4.0;
  }
}

/// 服务者等级筛选
class ProviderLevelFilter {
  /// 是否启用
  bool enabled;

  /// 选中的等级
  List<String> selectedLevels;

  ProviderLevelFilter({
    this.enabled = false,
    List<String>? selectedLevels,
  }) : selectedLevels = selectedLevels ?? [];

  /// 重置筛选条件
  void reset() {
    enabled = false;
    selectedLevels.clear();
  }
}
