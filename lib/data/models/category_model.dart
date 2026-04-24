class CategoryModel {
  final int id;
  final String name;
  final String? icon;
  final String? description;
  final int parentId;
  final int sort;
  final int hotValue;
  final int serviceCount;
  final int status;
  final DateTime createTime;
  final DateTime updateTime;

  CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.description,
    required this.parentId,
    required this.sort,
    required this.hotValue,
    required this.serviceCount,
    required this.status,
    required this.createTime,
    required this.updateTime,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      parentId: json['parentId'] is String ? int.parse(json['parentId']) : (json['parentId'] as int? ?? 0),
      sort: json['sort'] is String ? int.parse(json['sort']) : (json['sort'] as int? ?? 0),
      hotValue: json['hotValue'] is String ? int.parse(json['hotValue']) : (json['hotValue'] as int? ?? 0),
      serviceCount: json['serviceCount'] is String ? int.parse(json['serviceCount']) : (json['serviceCount'] as int? ?? 0),
      status: json['status'] is String ? int.parse(json['status']) : (json['status'] as int? ?? 1),
      createTime: DateTime.parse(json['createTime'] as String),
      updateTime: DateTime.parse(json['updateTime'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'parentId': parentId,
      'sort': sort,
      'hotValue': hotValue,
      'serviceCount': serviceCount,
      'status': status,
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime.toIso8601String(),
    };
  }

  bool get isPrimaryCategory => parentId == 0;
  bool get isHot => hotValue > 80;
}
