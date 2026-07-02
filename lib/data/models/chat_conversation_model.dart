class ChatConversationModel {
  final String conversationID;
  final String userID;
  final String title;
  final String? faceURL;
  final String lastMessage;
  final String timeText;
  final int unreadCount;
  final int timestamp;

  ChatConversationModel({
    required this.conversationID,
    required this.userID,
    required this.title,
    this.faceURL,
    required this.lastMessage,
    required this.timeText,
    required this.unreadCount,
    required this.timestamp,
  });

  ChatConversationModel copyWith({
    String? title,
    String? faceURL,
    String? lastMessage,
    String? timeText,
    int? unreadCount,
    int? timestamp,
  }) {
    return ChatConversationModel(
      conversationID: conversationID,
      userID: userID,
      title: title ?? this.title,
      faceURL: faceURL ?? this.faceURL,
      lastMessage: lastMessage ?? this.lastMessage,
      timeText: timeText ?? this.timeText,
      unreadCount: unreadCount ?? this.unreadCount,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
