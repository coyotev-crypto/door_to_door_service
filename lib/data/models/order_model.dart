/// 订单数据模型
import 'package:flutter/material.dart';

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
  final int status; // 0-待支付,1-待接单,2-已接单,3-待上门,4-服务中,5-已完成,6-已取消
  final String? createTime;
  final String? updateTime;

  // 退款相关
  final int refundStatus; // 0-无退款,1-申请中,2-已批准,3-已拒绝,4-已退款
  final String? refundReason;
  final String? refundAmount;

  // 核销相���
  final String? verificationCode; // 二维码数据/核销码
  final String? providerName; // 服务人员名称
  final String? providerPhone; // 服务人员电话
  final String? providerAvatar; // 服务人员头像

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
    this.verificationCode,
    this.providerName,
    this.providerPhone,
    this.providerAvatar,
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
      verificationCode: json['verificationCode'] as String?,
      providerName: json['providerName'] as String?,
      providerPhone: json['providerPhone'] as String?,
      providerAvatar: json['providerAvatar'] as String?,
    );
  }

  static int _parseStatus(dynamic status) {
    if (status is int) return status;
    if (status is String) {
      return switch (status) {
        'pending' => 0,
        'paid' => 1,
        'accepted' => 2,
        'en_route' => 3,
        'in_progress' => 4,
        'completed' => 5,
        'cancelled' => 6,
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
      'verificationCode': verificationCode,
      'providerName': providerName,
      'providerPhone': providerPhone,
      'providerAvatar': providerAvatar,
    };
  }

  String get statusText {
    switch (status) {
      case 0:
        return '待支付';
      case 1:
        return '待接单';
      case 2:
        return '已接单';
      case 3:
        return '待上门';
      case 4:
        return '服务中';
      case 5:
        return '已完成';
      case 6:
        return '已取消';
      default:
        return '未知';
    }
  }

  /// 是否应该显示二维码（已支付但未完成）
  bool get shouldShowQRCode {
    return status >= 1 && status < 5 && verificationCode != null;
  }

  /// 是否已支付
  bool get isPaid => status >= 1;

  /// 是否已完成
  bool get isCompleted => status == 5;

  /// 是否已取消
  bool get isCancelled => status == 6;

  /// 订单状态颜色
  Color get statusColor {
    switch (status) {
      case 0:
        return const Color(0xFFFF9500); // 待支付 - 橙色
      case 1:
      case 2:
      case 3:
      case 4:
        return const Color(0xFFC4956A); // 已支付 - 金色
      case 5:
        return const Color(0xFF4CAF50); // 已完成 - 绿色
      case 6:
        return const Color(0xFF999999); // 已取消 - 灰色
      default:
        return const Color(0xFF999999);
    }
  }
}
