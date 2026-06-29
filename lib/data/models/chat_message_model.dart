class ChatMessageModel {
  final String clientMsgID;
  final String sendID;
  final String recvID;
  final String content;
  final int sendTime;
  final bool isSelf;
  final bool isSending;
  final bool isSendFailed;

  ChatMessageModel({
    required this.clientMsgID,
    required this.sendID,
    required this.recvID,
    required this.content,
    required this.sendTime,
    required this.isSelf,
    this.isSending = false,
    this.isSendFailed = false,
  });
}
