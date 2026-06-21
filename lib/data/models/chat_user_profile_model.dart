class ChatUserProfileModel {
  final int userId;
  final String? nickname;
  final String? avatarUrl;

  ChatUserProfileModel({
    required this.userId,
    this.nickname,
    this.avatarUrl,
  });

  factory ChatUserProfileModel.fromJson(Map<String, dynamic> json) {
    return ChatUserProfileModel(
      userId: json['userId'] is int
          ? json['userId'] as int
          : int.tryParse(json['userId']?.toString() ?? '') ?? 0,
      nickname: json['nickname']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }
}
