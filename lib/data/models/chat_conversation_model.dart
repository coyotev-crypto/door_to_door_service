class ChatConversationModel {
  final String conversationID;
  final String userID;
  final String title;
  final String? faceURL;
  final String lastMessage;
  final int unreadCount;
  final int timestamp;

  ChatConversationModel({
    required this.conversationID,
    required this.userID,
    required this.title,
    this.faceURL,
    required this.lastMessage,
    required this.unreadCount,
    required this.timestamp,
  });
}
