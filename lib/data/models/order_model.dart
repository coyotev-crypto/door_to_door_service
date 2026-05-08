/// 订单数据模型
class OrderModel {
  final int id;
  final int serviceId;
  final String? serviceName;
  final double? servicePrice;
  final double? travelFee;
  final double? totalPrice;
  final String? addressName;
  final double? latitude;
  final double? longitude;
  final String? contactName;
  final String? contactPhone;
  final String? remark;
  final int status; // 0-待支付,1-待服务,2-进行中,3-已完成,4-已取消
  final String? createTime;
  final String? updateTime;

  OrderModel({
    this.id = 0,
    required this.serviceId,
    this.serviceName,
    this.servicePrice,
    this.travelFee,
    this.totalPrice,
    this.addressName,
    this.latitude,
    this.longitude,
    this.contactName,
    this.contactPhone,
    this.remark,
    this.status = 0,
    this.createTime,
    this.updateTime,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] is String ? int.parse(json['id']) : (json['id'] as int? ?? 0),
      serviceId: json['serviceId'] is String
          ? int.parse(json['serviceId'])
          : (json['serviceId'] as int? ?? 0),
      serviceName: json['serviceName'] as String?,
      servicePrice: (json['servicePrice'] as num?)?.toDouble(),
      travelFee: (json['travelFee'] as num?)?.toDouble(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      addressName: json['addressName'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      contactName: json['contactName'] as String?,
      contactPhone: json['contactPhone'] as String?,
      remark: json['remark'] as String?,
      status: json['status'] is String
          ? int.parse(json['status'])
          : (json['status'] as int? ?? 0),
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'servicePrice': servicePrice,
      'travelFee': travelFee,
      'totalPrice': totalPrice,
      'addressName': addressName,
      'latitude': latitude,
      'longitude': longitude,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'remark': remark,
      'status': status,
      'createTime': createTime,
      'updateTime': updateTime,
    };
  }

  String get statusText {
    switch (status) {
      case 0:
        return '待支付';
      case 1:
        return '待服务';
      case 2:
        return '进行中';
      case 3:
        return '已完成';
      case 4:
        return '已取消';
      default:
        return '未知';
    }
  }
}
