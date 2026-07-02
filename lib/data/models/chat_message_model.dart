import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';

enum ChatMessageType {
  text,
  image,
  video,
  voice,
  file,
  location,
  custom,
  unsupported,
}

class ChatMessageModel {
  final String clientMsgID;
  final String? serverMsgID;
  final String sendID;
  final String recvID;
  final int sendTime;
  final bool isSelf;
  final bool isSending;
  final bool isSendFailed;
  final bool isRead;
  final bool isRevoked;
  final ChatMessageType type;
  final String? text;
  final String? imageUrl;
  final String? imageLocalPath;
  final int? imageWidth;
  final int? imageHeight;
  final String? videoUrl;
  final String? videoLocalPath;
  final String? videoSnapshotUrl;
  final String? videoSnapshotLocalPath;
  final int? videoDuration;
  final String? senderFaceUrl;
  final String? senderNickname;
  final String? voiceUrl;
  final String? voiceLocalPath;
  final int? voiceDuration;
  final String? fileName;
  final String? fileUrl;
  final String? fileLocalPath;
  final int? fileSize;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final Message rawMessage;

  ChatMessageModel({
    required this.clientMsgID,
    required this.sendID,
    required this.recvID,
    required this.sendTime,
    required this.isSelf,
    required this.type,
    required this.rawMessage,
    this.serverMsgID,
    this.isSending = false,
    this.isSendFailed = false,
    this.isRead = false,
    this.isRevoked = false,
    this.text,
    this.imageUrl,
    this.imageLocalPath,
    this.imageWidth,
    this.imageHeight,
    this.videoUrl,
    this.videoLocalPath,
    this.videoSnapshotUrl,
    this.videoSnapshotLocalPath,
    this.videoDuration,
    this.senderFaceUrl,
    this.senderNickname,
    this.voiceUrl,
    this.voiceLocalPath,
    this.voiceDuration,
    this.fileName,
    this.fileUrl,
    this.fileLocalPath,
    this.fileSize,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  ChatMessageModel copyWith({
    String? clientMsgID,
    String? serverMsgID,
    String? sendID,
    String? recvID,
    int? sendTime,
    bool? isSelf,
    bool? isSending,
    bool? isSendFailed,
    bool? isRead,
    bool? isRevoked,
    ChatMessageType? type,
    String? text,
    String? imageUrl,
    String? imageLocalPath,
    int? imageWidth,
    int? imageHeight,
    String? videoUrl,
    String? videoLocalPath,
    String? videoSnapshotUrl,
    String? videoSnapshotLocalPath,
    int? videoDuration,
    String? senderFaceUrl,
    String? senderNickname,
    String? voiceUrl,
    String? voiceLocalPath,
    int? voiceDuration,
    String? fileName,
    String? fileUrl,
    String? fileLocalPath,
    int? fileSize,
    double? latitude,
    double? longitude,
    String? locationName,
    Message? rawMessage,
  }) {
    return ChatMessageModel(
      clientMsgID: clientMsgID ?? this.clientMsgID,
      serverMsgID: serverMsgID ?? this.serverMsgID,
      sendID: sendID ?? this.sendID,
      recvID: recvID ?? this.recvID,
      sendTime: sendTime ?? this.sendTime,
      isSelf: isSelf ?? this.isSelf,
      isSending: isSending ?? this.isSending,
      isSendFailed: isSendFailed ?? this.isSendFailed,
      isRead: isRead ?? this.isRead,
      isRevoked: isRevoked ?? this.isRevoked,
      type: type ?? this.type,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      imageLocalPath: imageLocalPath ?? this.imageLocalPath,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      videoUrl: videoUrl ?? this.videoUrl,
      videoLocalPath: videoLocalPath ?? this.videoLocalPath,
      videoSnapshotUrl: videoSnapshotUrl ?? this.videoSnapshotUrl,
      videoSnapshotLocalPath:
          videoSnapshotLocalPath ?? this.videoSnapshotLocalPath,
      videoDuration: videoDuration ?? this.videoDuration,
      senderFaceUrl: senderFaceUrl ?? this.senderFaceUrl,
      senderNickname: senderNickname ?? this.senderNickname,
      voiceUrl: voiceUrl ?? this.voiceUrl,
      voiceLocalPath: voiceLocalPath ?? this.voiceLocalPath,
      voiceDuration: voiceDuration ?? this.voiceDuration,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileLocalPath: fileLocalPath ?? this.fileLocalPath,
      fileSize: fileSize ?? this.fileSize,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      rawMessage: rawMessage ?? this.rawMessage,
    );
  }
}
