class OpenIMTokenModel {
  final String openIMUserID;
  final String token;
  final int? expireAt;
  final String apiAddr;
  final String wsAddr;
  final int? platformID;

  OpenIMTokenModel({
    required this.openIMUserID,
    required this.token,
    this.expireAt,
    required this.apiAddr,
    required this.wsAddr,
    this.platformID,
  });

  factory OpenIMTokenModel.fromJson(Map<String, dynamic> json) {
    return OpenIMTokenModel(
      openIMUserID: json['openIMUserID']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      expireAt: json['expireAt'] is int
          ? json['expireAt'] as int
          : int.tryParse(json['expireAt']?.toString() ?? ''),
      apiAddr: json['apiAddr']?.toString() ?? '',
      wsAddr: json['wsAddr']?.toString() ?? '',
      platformID: json['platformID'] is int
          ? json['platformID'] as int
          : int.tryParse(json['platformID']?.toString() ?? ''),
    );
  }
}
