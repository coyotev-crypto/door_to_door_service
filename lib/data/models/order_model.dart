/// 订单数据模型
class OrderModel {
  final int id;
  final String? orderNo;
  final int serviceId;
  final int? durationMinutes;
  final String? serviceName;
  final String? servicePrice;
  final String? travelFee;
  final String? totalPrice;
  final String? addressName;
  final double? latitude;
  final double? longitude;
  final String? contactName;
  final String? contactPhone;
  final String? serviceTime;
  final String? remark;
  final int status; // 0-待支付,1-待服务,2-进行中,3-已完成,4-已取消
  final String? createTime;
  final String? updateTime;

  // 退款相关
  final int refundStatus; // 0-无退款,1-申请中,2-已批准,3-已拒绝,4-已退款
  final String? refundReason;
  final String? refundAmount;

  OrderModel({
    this.id = 0,
    this.orderNo,
    required this.serviceId,
    this.durationMinutes,
    this.serviceName,
    this.servicePrice,
    this.travelFee,
    this.totalPrice,
    this.addressName,
    this.latitude,
    this.longitude,
    this.contactName,
    this.contactPhone,
    this.serviceTime,
    this.remark,
    this.status = 0,
    this.createTime,
    this.updateTime,
    this.refundStatus = 0,
    this.refundReason,
    this.refundAmount,
  });

  /// 解析 decimal 字符串为 double
  static double? _parseDecimal(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) {
      final parsed = double.tryParse(v);
      return parsed;
    }
    return null;
  }

  /// 总价数值（用于计算和比较）
  double? get totalPriceValue => _parseDecimal(totalPrice);

  /// 出行费数值
  double? get travelFeeValue => _parseDecimal(travelFee);

  /// 服务价格数值
  double? get servicePriceValue => _parseDecimal(servicePrice);

  /// 退款金额数值
  double? get refundAmountValue => _parseDecimal(refundAmount);

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] is String ? int.parse(json['id']) : (json['id'] as int? ?? 0),
      orderNo: json['orderNo'] as String?,
      serviceId: json['serviceId'] is String
          ? int.parse(json['serviceId'])
          : (json['serviceId'] as int? ?? 0),
      durationMinutes: json['durationMinutes'] as int?,
      serviceName: json['serviceName'] as String?,
      servicePrice: json['servicePrice']?.toString(),
      travelFee: json['travelFee']?.toString() ?? json['deliveryFee']?.toString(),
      totalPrice: json['totalPrice']?.toString() ?? json['totalAmount']?.toString(),
      addressName: json['addressName'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      contactName: json['contactName'] as String?,
      contactPhone: json['contactPhone'] as String?,
      serviceTime: json['serviceTime'] as String? ?? json['startTime'] as String?,
      remark: json['remark'] as String?,
      status: _parseStatus(json['status']),
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
      refundStatus: json['refundStatus'] as int? ?? 0,
      refundReason: json['refundReason'] as String?,
      refundAmount: json['refundAmount']?.toString(),
    );
  }

  static int _parseStatus(dynamic status) {
    if (status is int) return status;
    if (status is String) {
      return switch (status) {
        'pending' => 0,
        'confirmed' => 1,
        'in_progress' => 2,
        'completed' => 3,
        'cancelled' => 4,
        _ => int.tryParse(status) ?? 0,
      };
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNo': orderNo,
      'serviceId': serviceId,
      'durationMinutes': durationMinutes,
      'serviceName': serviceName,
      'servicePrice': servicePrice,
      'travelFee': travelFee,
      'totalPrice': totalPrice,
      'addressName': addressName,
      'latitude': latitude,
      'longitude': longitude,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'serviceTime': serviceTime,
      'remark': remark,
      'status': status,
      'createTime': createTime,
      'updateTime': updateTime,
      'refundStatus': refundStatus,
      'refundReason': refundReason,
      'refundAmount': refundAmount,
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
