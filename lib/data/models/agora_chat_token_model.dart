class AgoraChatTokenModel {
  final String appKey;
  final String chatUserId;
  final String token;
  final int? expireAt;

  AgoraChatTokenModel({
    required this.appKey,
    required this.chatUserId,
    required this.token,
    this.expireAt,
  });

  factory AgoraChatTokenModel.fromJson(Map<String, dynamic> json) {
    return AgoraChatTokenModel(
      appKey: json['appKey']?.toString() ?? '',
      chatUserId: json['chatUserId']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      expireAt: json['expireAt'] is int
          ? json['expireAt'] as int
          : int.tryParse(json['expireAt']?.toString() ?? ''),
    );
  }
}
