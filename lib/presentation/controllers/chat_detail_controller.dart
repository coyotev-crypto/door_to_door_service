import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/location_service.dart';
import '../../core/services/openim_chat_service.dart';
import '../../core/utils/log_util.dart';
import '../../data/models/chat_message_model.dart';

class ChatDetailController extends GetxController {
  static const String tag = 'ChatDetailController';

  ChatDetailController({
    required this.userID,
    this.initialConversationID,
  });

  final String userID;
  final String? initialConversationID;
  final OpenIMChatService _chatService = Get.isRegistered<OpenIMChatService>()
      ? OpenIMChatService.to
      : Get.put(OpenIMChatService(), permanent: true);
  final LocationService? _locationService = Get.isRegistered<LocationService>()
      ? Get.find<LocationService>()
      : null;

  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxBool isInitialLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString title = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxBool showNewMessageIndicator = false.obs;
  final RxnString playingVoiceID = RxnString();

  final ScrollController scrollController = ScrollController();
  final TextEditingController inputController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  ConversationInfo? _conversationInfo;
  Message? _oldestMessage;
  StreamSubscription<Message?>? _newMessageSub;
  StreamSubscription<List<ReadReceiptInfo>?>? _readReceiptSub;
  StreamSubscription<RevokedInfo?>? _messageRevokedSub;
  DateTime? _recordStartAt;
  String? _recordPath;
  bool _isFirstLoad = true;
  bool _isLoadingHistory = false;

  @override
  void onInit() {
    super.onInit();
    title.value = userID;
    _newMessageSub = _chatService.newMessage.listen((message) {
      if (message != null) _handleNewMessage(message);
    });
    _readReceiptSub = _chatService.readReceipt.listen((list) {
      if (list != null) _handleReadReceipt(list);
    });
    _messageRevokedSub = _chatService.messageRevoked.listen((info) {
      if (info != null) _handleMessageRevoked(info);
    });
    scrollController.addListener(_handleScroll);
    _init();
  }

  @override
  void onClose() {
    _newMessageSub?.cancel();
    _readReceiptSub?.cancel();
    _messageRevokedSub?.cancel();
    scrollController.removeListener(_handleScroll);
    scrollController.dispose();
    inputController.dispose();
    focusNode.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.onClose();
  }

  Future<void> _init() async {
    isInitialLoading.value = true;
    errorMessage.value = '';
    try {
      await _prepareConversation();
      await loadHistory(refresh: true);
    } catch (e) {
      LogUtil.e('Init chat detail failed: $e', tag: tag);
      errorMessage.value = '聊天加载失败，请稍后重试';
    } finally {
      isInitialLoading.value = false;
    }
  }

  Future<void> loadHistory({bool refresh = false}) async {
    if (userID.isEmpty) return;
    if (!refresh && !hasMore.value) return;
    if (_isLoadingHistory) return;

    _isLoadingHistory = true;
    if (refresh) {
      isInitialLoading.value = true;
      errorMessage.value = '';
    } else {
      isLoadingMore.value = true;
    }
    try {
      await _chatService.ensureLoggedIn();
      final conversation = await _ensureConversation();
      final result =
          await OpenIM.iMManager.messageManager.getAdvancedHistoryMessageList(
        conversationID: conversation.conversationID,
        count: 40,
        startMsg: refresh || _isFirstLoad ? null : _oldestMessage,
      );
      final list = result.messageList ?? [];
      final mapped =
          list.map(_mapMessage).whereType<ChatMessageModel>().toList();

      if (refresh || _isFirstLoad) {
        messages.assignAll(mapped);
      } else {
        _appendHistory(mapped);
      }

      _oldestMessage = list.isNotEmpty ? list.last : _oldestMessage;
      _isFirstLoad = false;
      hasMore.value = result.isEnd != true && list.isNotEmpty;
      await markRead();
    } catch (e) {
      LogUtil.e('Load chat history failed: $e', tag: tag);
      errorMessage.value = '消息加载失败';
    } finally {
      isInitialLoading.value = false;
      isLoadingMore.value = false;
      _isLoadingHistory = false;
    }
  }

  Future<void> sendText(String text) async {
    final content = text.trim();
    if (content.isEmpty) return;

    await _chatService.ensureLoggedIn();
    final message = await OpenIM.iMManager.messageManager.createTextMessage(
      text: content,
    );
    await _sendMessage(message, offlineTitle: '新消息', offlineDesc: content);
  }

  Future<void> pickAndSendImage() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      await _chatService.ensureLoggedIn();
      final message =
          await OpenIM.iMManager.messageManager.createImageMessageFromFullPath(
        imagePath: image.path,
      );
      await _sendMessage(message, offlineTitle: '图片消息', offlineDesc: '[图片]');
    } catch (e) {
      LogUtil.e('Pick or send image failed: $e', tag: tag);
      Get.snackbar('发送失败', '图片发送失败，请稍后重试');
    }
  }

  Future<void> startRecordVoice() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        Get.snackbar('无法录音', '请开启麦克风权限');
        return;
      }
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/openim_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      _recordPath = path;
      _recordStartAt = DateTime.now();
    } catch (e) {
      LogUtil.e('Start record failed: $e', tag: tag);
      Get.snackbar('录音失败', '无法开始录音');
    }
  }

  Future<void> stopRecordAndSendVoice() async {
    try {
      final path = await _audioRecorder.stop() ?? _recordPath;
      final startedAt = _recordStartAt;
      _recordPath = null;
      _recordStartAt = null;
      if (path == null || startedAt == null) return;

      final duration = DateTime.now().difference(startedAt).inSeconds;
      if (duration < 1) {
        Get.snackbar('录音太短', '请至少录制 1 秒');
        return;
      }

      await _chatService.ensureLoggedIn();
      final message =
          await OpenIM.iMManager.messageManager.createSoundMessageFromFullPath(
        soundPath: path,
        duration: duration,
      );
      await _sendMessage(message, offlineTitle: '语音消息', offlineDesc: '[语音]');
    } catch (e) {
      LogUtil.e('Stop record failed: $e', tag: tag);
      Get.snackbar('发送失败', '语音发送失败，请稍后重试');
    }
  }

  Future<void> pickAndSendFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(withData: false);
      final file = result?.files.single;
      final path = file?.path;
      if (file == null || path == null || path.isEmpty) return;

      await _chatService.ensureLoggedIn();
      final message =
          await OpenIM.iMManager.messageManager.createFileMessageFromFullPath(
        filePath: path,
        fileName: file.name,
      );
      await _sendMessage(message, offlineTitle: '文件消息', offlineDesc: file.name);
    } catch (e) {
      LogUtil.e('Pick or send file failed: $e', tag: tag);
      Get.snackbar('发送失败', '文件发送失败，请稍后重试');
    }
  }

  Future<void> sendCurrentLocation() async {
    try {
      final service = _locationService;
      if (service == null) {
        Get.snackbar('发送失败', '定位服务不可用');
        return;
      }
      final location = service.currentLocation ?? await service.getLocationOnce();
      final latitude = location?.latitude;
      final longitude = location?.longitude;
      if (latitude == null || longitude == null) {
        Get.snackbar('发送失败', '无法获取当前位置');
        return;
      }
      final desc = location?.address ?? location?.city ?? '当前位置';

      await _chatService.ensureLoggedIn();
      final message = await OpenIM.iMManager.messageManager.createLocationMessage(
        latitude: latitude,
        longitude: longitude,
        description: desc,
      );
      await _sendMessage(message, offlineTitle: '位置消息', offlineDesc: '[位置]');
    } catch (e) {
      LogUtil.e('Send location failed: $e', tag: tag);
      Get.snackbar('发送失败', '位置发送失败，请稍后重试');
    }
  }

  Future<void> openFile(ChatMessageModel message) async {
    final path = message.fileLocalPath;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      await OpenFilex.open(path);
      return;
    }
    final url = message.fileUrl;
    if (url != null && url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    Get.snackbar('无法打开', '文件尚未下载到本地');
  }

  Future<void> playVoice(ChatMessageModel message) async {
    final path = message.voiceLocalPath;
    final url = message.voiceUrl;
    final source = path != null && path.isNotEmpty && File(path).existsSync()
        ? path
        : url;
    if (source == null || source.isEmpty) {
      Get.snackbar('无法播放', '语音文件不可用');
      return;
    }

    try {
      if (playingVoiceID.value == message.clientMsgID) {
        await _audioPlayer.stop();
        playingVoiceID.value = null;
        return;
      }

      playingVoiceID.value = message.clientMsgID;
      if (source == path) {
        await _audioPlayer.setFilePath(source);
      } else {
        await _audioPlayer.setUrl(source);
      }
      await _audioPlayer.play();
      playingVoiceID.value = null;
    } catch (e) {
      LogUtil.e('Play voice failed: $e', tag: tag);
      playingVoiceID.value = null;
      Get.snackbar('播放失败', '语音播放失败');
    }
  }

  Future<void> openLocation(ChatMessageModel message) async {
    final latitude = message.latitude;
    final longitude = message.longitude;
    if (latitude == null || longitude == null) return;
    final label = Uri.encodeComponent(message.locationName ?? '位置');
    final uri = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude($label)');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    Get.snackbar('无法打开地图', '${message.locationName ?? '位置'}\n$latitude, $longitude');
  }

  Future<void> retryMessage(ChatMessageModel message) async {
    messages.removeWhere((item) => item.clientMsgID == message.clientMsgID);

    if (message.type == ChatMessageType.text) {
      final text = message.text?.trim();
      if (text == null || text.isEmpty) return;
      await sendText(text);
      return;
    }

    if (message.type == ChatMessageType.image) {
      final path = message.imageLocalPath?.trim();
      if (path == null || path.isEmpty) return;
      await _chatService.ensureLoggedIn();
      final retry =
          await OpenIM.iMManager.messageManager.createImageMessageFromFullPath(
        imagePath: path,
      );
      await _sendMessage(retry, offlineTitle: '图片消息', offlineDesc: '[图片]');
      return;
    }

    if (message.type == ChatMessageType.voice) {
      final path = message.voiceLocalPath?.trim();
      final duration = message.voiceDuration;
      if (path == null || path.isEmpty || duration == null) return;
      await _chatService.ensureLoggedIn();
      final retry =
          await OpenIM.iMManager.messageManager.createSoundMessageFromFullPath(
        soundPath: path,
        duration: duration,
      );
      await _sendMessage(retry, offlineTitle: '语音消息', offlineDesc: '[语音]');
      return;
    }

    if (message.type == ChatMessageType.file) {
      final path = message.fileLocalPath?.trim();
      final name = message.fileName?.trim();
      if (path == null || path.isEmpty || name == null || name.isEmpty) return;
      await _chatService.ensureLoggedIn();
      final retry =
          await OpenIM.iMManager.messageManager.createFileMessageFromFullPath(
        filePath: path,
        fileName: name,
      );
      await _sendMessage(retry, offlineTitle: '文件消息', offlineDesc: name);
      return;
    }

    if (message.type == ChatMessageType.location) {
      final latitude = message.latitude;
      final longitude = message.longitude;
      if (latitude == null || longitude == null) return;
      await _chatService.ensureLoggedIn();
      final retry = await OpenIM.iMManager.messageManager.createLocationMessage(
        latitude: latitude,
        longitude: longitude,
        description: message.locationName ?? '位置',
      );
      await _sendMessage(retry, offlineTitle: '位置消息', offlineDesc: '[位置]');
    }
  }

  Future<void> copyMessage(ChatMessageModel message) async {
    if (message.type != ChatMessageType.text || message.isRevoked) return;
    final text = message.text;
    if (text == null || text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    Get.snackbar('已复制', '消息内容已复制');
  }

  Future<void> deleteLocalMessage(ChatMessageModel message) async {
    try {
      final conversation = await _ensureConversation();
      await OpenIM.iMManager.messageManager.deleteMessageFromLocalStorage(
        conversationID: conversation.conversationID,
        clientMsgID: message.clientMsgID,
      );
      messages.removeWhere((item) => item.clientMsgID == message.clientMsgID);
    } catch (e) {
      LogUtil.e('Delete local message failed: $e', tag: tag);
      Get.snackbar('删除失败', '消息删除失败，请稍后重试');
    }
  }

  Future<void> revokeMessage(ChatMessageModel message) async {
    if (!message.isSelf || message.isSending || message.isSendFailed) return;

    try {
      final conversation = await _ensureConversation();
      await OpenIM.iMManager.messageManager.revokeMessage(
        conversationID: conversation.conversationID,
        clientMsgID: message.clientMsgID,
      );
      _markMessageRevoked(message.clientMsgID);
      await _chatService.refreshConversations();
    } catch (e) {
      LogUtil.e('Revoke message failed: $e', tag: tag);
      Get.snackbar('撤回失败', '消息撤回失败，请稍后重试');
    }
  }

  Future<void> markRead() async {
    try {
      final conversation = await _ensureConversation();
      await OpenIM.iMManager.conversationManager.markConversationMessageAsRead(
        conversationID: conversation.conversationID,
      );
      await _chatService.refreshConversations();
    } catch (e) {
      LogUtil.e('Mark conversation read failed: $e', tag: tag);
    }
  }

  void scrollToBottom() {
    if (!scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
      showNewMessageIndicator.value = false;
    });
  }

  Future<void> _sendMessage(
    Message message, {
    required String offlineTitle,
    required String offlineDesc,
  }) async {
    final pending = _mapMessage(message, isSending: true);
    if (pending != null) {
      _upsertMessage(pending);
      scrollToBottom();
    }

    try {
      final sent = await OpenIM.iMManager.messageManager.sendMessage(
        message: message,
        offlinePushInfo: OfflinePushInfo(
          title: offlineTitle,
          desc: offlineDesc,
        ),
        userID: userID,
      );
      _replaceMessage(sent);
      await _chatService.refreshConversations();
    } catch (e) {
      LogUtil.e('Send message failed: $e', tag: tag);
      _markMessageFailed(message.clientMsgID);
    }
  }

  Future<void> _prepareConversation() async {
    _conversationInfo = await _ensureConversation();
  }

  Future<ConversationInfo> _ensureConversation() async {
    final current = _conversationInfo;
    if (current != null) return current;

    await _chatService.ensureLoggedIn();

    final conversationID = initialConversationID?.trim();
    if (conversationID != null && conversationID.isNotEmpty) {
      final list =
          await OpenIM.iMManager.conversationManager.getMultipleConversation(
        conversationIDList: [conversationID],
      );
      if (list.isNotEmpty) {
        _conversationInfo = list.first;
        _updateTitle(list.first);
        return _conversationInfo!;
      }
    }

    _conversationInfo =
        await OpenIM.iMManager.conversationManager.getOneConversation(
      sourceID: userID,
      sessionType: ConversationType.single,
    );
    _updateTitle(_conversationInfo!);
    return _conversationInfo!;
  }

  void _updateTitle(ConversationInfo conversation) {
    final showName = conversation.showName?.trim();
    title.value = showName == null || showName.isEmpty ? userID : showName;
  }

  void _handleNewMessage(Message message) {
    if (!_isCurrentChat(message)) return;

    final mapped = _mapMessage(message);
    if (mapped == null) return;

    _upsertMessage(mapped);
    if (_isNearBottom) {
      scrollToBottom();
    } else {
      showNewMessageIndicator.value = true;
    }
    markRead();
  }

  void _handleReadReceipt(List<ReadReceiptInfo> list) {
    final readIDs = <String>{};
    for (final receipt in list) {
      final fromUser = receipt.userID;
      if (fromUser != null && fromUser != userID) continue;
      readIDs.addAll(receipt.msgIDList ?? const <String>[]);
    }
    if (readIDs.isEmpty) return;

    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      if (message.isSelf && readIDs.contains(message.clientMsgID)) {
        messages[i] = message.copyWith(isRead: true);
      }
    }
  }

  void _handleMessageRevoked(RevokedInfo info) {
    final sourceID = info.sourceMessageSendID;
    if (sourceID != null &&
        sourceID != userID &&
        sourceID != _chatService.currentUserID) {
      return;
    }
    final clientMsgID = info.clientMsgID;
    if (clientMsgID == null || clientMsgID.isEmpty) return;
    _markMessageRevoked(clientMsgID);
  }

  bool _isCurrentChat(Message message) {
    final sendID = message.sendID;
    final recvID = message.recvID;
    final currentUserID = _chatService.currentUserID;
    return sendID == userID || (sendID == currentUserID && recvID == userID);
  }

  ChatMessageModel? _mapMessage(Message message, {bool isSending = false}) {
    final type = _mapMessageType(message);
    final content = message.textElem?.content ?? message.atTextElem?.text;
    final picture = message.pictureElem;
    final sound = message.soundElem;
    final file = message.fileElem;
    final location = message.locationElem;

    final sendID = message.sendID ?? '';
    final recvID = message.recvID ?? '';
    return ChatMessageModel(
      clientMsgID: message.clientMsgID ?? '',
      serverMsgID: message.serverMsgID,
      sendID: sendID,
      recvID: recvID,
      sendTime: message.sendTime ?? DateTime.now().millisecondsSinceEpoch,
      isSelf: sendID == _chatService.currentUserID,
      isSending: isSending || message.status == MessageStatus.sending,
      isSendFailed: message.status == MessageStatus.failed,
      isRead: message.isRead == true,
      isRevoked: message.contentType == MessageType.revokeMessageNotification,
      type: type,
      text: content,
      imageUrl: picture?.snapshotPicture?.url ??
          picture?.sourcePicture?.url ??
          picture?.bigPicture?.url,
      imageLocalPath: picture?.sourcePath,
      voiceUrl: sound?.sourceUrl,
      voiceLocalPath: sound?.soundPath,
      voiceDuration: sound?.duration,
      fileName: file?.fileName,
      fileUrl: file?.sourceUrl,
      fileLocalPath: file?.filePath,
      fileSize: file?.fileSize,
      latitude: location?.latitude,
      longitude: location?.longitude,
      locationName: location?.description,
      rawMessage: message,
    );
  }

  void _replaceMessage(Message message) {
    final mapped = _mapMessage(message);
    if (mapped == null) return;
    _upsertMessage(mapped);
  }

  void _upsertMessage(ChatMessageModel message) {
    final index = messages.indexWhere(
      (item) => item.clientMsgID == message.clientMsgID,
    );
    if (index >= 0) {
      messages[index] = message;
    } else {
      messages.insert(0, message);
    }
  }

  void _appendHistory(List<ChatMessageModel> history) {
    final exists = messages.map((item) => item.clientMsgID).toSet();
    final deduped =
        history.where((item) => !exists.contains(item.clientMsgID)).toList();
    messages.addAll(deduped);
  }

  void _markMessageFailed(String? clientMsgID) {
    if (clientMsgID == null || clientMsgID.isEmpty) return;

    final index = messages.indexWhere((item) => item.clientMsgID == clientMsgID);
    if (index < 0) return;
    final old = messages[index];
    messages[index] = old.copyWith(
      isSending: false,
      isSendFailed: true,
    );
  }

  void _markMessageRevoked(String clientMsgID) {
    final index = messages.indexWhere((item) => item.clientMsgID == clientMsgID);
    if (index < 0) return;
    final old = messages[index];
    messages[index] = old.copyWith(
      isRevoked: true,
      isSending: false,
      isSendFailed: false,
    );
  }

  ChatMessageType _mapMessageType(Message message) {
    switch (message.contentType) {
      case MessageType.text:
      case MessageType.atText:
        return ChatMessageType.text;
      case MessageType.picture:
        return ChatMessageType.image;
      case MessageType.voice:
        return ChatMessageType.voice;
      case MessageType.file:
        return ChatMessageType.file;
      case MessageType.location:
        return ChatMessageType.location;
      case MessageType.custom:
        return ChatMessageType.custom;
      default:
        return ChatMessageType.unsupported;
    }
  }

  void _handleScroll() {
    if (!scrollController.hasClients) return;

    if (scrollController.position.pixels >
        scrollController.position.maxScrollExtent - 120) {
      loadHistory();
    }

    if (_isNearBottom) {
      showNewMessageIndicator.value = false;
    }
  }

  bool get _isNearBottom {
    if (!scrollController.hasClients) return true;
    return scrollController.position.pixels < 80;
  }
}
