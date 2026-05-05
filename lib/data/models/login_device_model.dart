/// 登录设备模型
class LoginDeviceModel {
  final String id;
  final String deviceName;
  final String deviceType; // 设备类型：android, ios, web
  final String? ipAddress;
  final String? location;
  final DateTime? lastLoginTime;
  final bool isCurrentDevice;

  LoginDeviceModel({
    required this.id,
    required this.deviceName,
    required this.deviceType,
    this.ipAddress,
    this.location,
    this.lastLoginTime,
    required this.isCurrentDevice,
  });

  factory LoginDeviceModel.fromJson(Map<String, dynamic> json) {
    return LoginDeviceModel(
      id: json['id']?.toString() ?? '',
      deviceName: json['deviceName']?.toString() ?? '',
      deviceType: json['deviceType']?.toString() ?? '',
      ipAddress: json['ipAddress']?.toString(),
      location: json['location']?.toString(),
      lastLoginTime: json['lastLoginTime'] != null
          ? DateTime.tryParse(json['lastLoginTime'])
          : null,
      isCurrentDevice: json['isCurrentDevice'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'ipAddress': ipAddress,
      'location': location,
      'lastLoginTime': lastLoginTime?.toIso8601String(),
      'isCurrentDevice': isCurrentDevice,
    };
  }

  /// 获取设备类型显示名称
  String get deviceTypeDisplayName {
    switch (deviceType.toLowerCase()) {
      case 'android':
        return 'Android';
      case 'ios':
        return 'iOS';
      case 'web':
        return '网页';
      default:
        return '其他';
    }
  }
}
