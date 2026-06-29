import 'dart:async';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';

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

  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxString title = ''.obs;

  ConversationInfo? _conversationInfo;
  Message? _oldestMessage;
  StreamSubscription<Message?>? _newMessageSub;
  bool _isFirstLoad = true;

  @override
  void onInit() {
    super.onInit();
    title.value = userID;
    _newMessageSub = _chatService.newMessage.listen((message) {
      if (message != null) {
        _handleNewMessage(message);
      }
    });
    _init();
  }

  @override
  void onClose() {
    _newMessageSub?.cancel();
    super.onClose();
  }

  Future<void> _init() async {
    isLoading.value = true;
    try {
      await _prepareConversation();
      await loadHistory(refresh: true);
    } catch (e) {
      LogUtil.e('Init chat detail failed: $e', tag: tag);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadHistory({bool refresh = false}) async {
    if (userID.isEmpty) return;
    if (!refresh && !hasMore.value) return;

    isLoading.value = true;
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
      final mapped = list.map(_mapMessage).whereType<ChatMessageModel>().toList();

      if (refresh || _isFirstLoad) {
        messages.assignAll(mapped.reversed);
      } else {
        messages.insertAll(0, mapped.reversed);
      }

      _oldestMessage = list.isNotEmpty ? list.first : _oldestMessage;
      _isFirstLoad = false;
      hasMore.value = result.isEnd != true && list.isNotEmpty;
      await markRead();
    } catch (e) {
      LogUtil.e('Load chat history failed: $e', tag: tag);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendText(String text) async {
    final content = text.trim();
    if (content.isEmpty) return;

    await _chatService.ensureLoggedIn();

    final message = await OpenIM.iMManager.messageManager.createTextMessage(
      text: content,
    );
    final pending = _mapMessage(message, isSending: true);
    if (pending != null) {
      messages.add(pending);
    }

    try {
      final sent = await OpenIM.iMManager.messageManager.sendMessage(
        message: message,
        offlinePushInfo: OfflinePushInfo(
          title: '新消息',
          desc: content,
        ),
        userID: userID,
      );
      _replaceMessage(sent);
      await _chatService.refreshConversations();
    } catch (e) {
      LogUtil.e('Send text failed: $e', tag: tag);
      _markMessageFailed(message.clientMsgID);
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
    if (messages.any((item) => item.clientMsgID == mapped.clientMsgID)) return;

    messages.add(mapped);
    markRead();
  }

  bool _isCurrentChat(Message message) {
    final sendID = message.sendID;
    final recvID = message.recvID;
    final currentUserID = _chatService.currentUserID;
    return sendID == userID || (sendID == currentUserID && recvID == userID);
  }

  ChatMessageModel? _mapMessage(Message message, {bool isSending = false}) {
    final content = message.textElem?.content;
    if (content == null || content.isEmpty) return null;

    final sendID = message.sendID ?? '';
    final recvID = message.recvID ?? '';
    return ChatMessageModel(
      clientMsgID: message.clientMsgID ?? '',
      sendID: sendID,
      recvID: recvID,
      content: content,
      sendTime: message.sendTime ?? DateTime.now().millisecondsSinceEpoch,
      isSelf: sendID == _chatService.currentUserID,
      isSending: isSending,
    );
  }

  void _replaceMessage(Message message) {
    final mapped = _mapMessage(message);
    if (mapped == null) return;

    final index = messages.indexWhere(
      (item) => item.clientMsgID == mapped.clientMsgID,
    );
    if (index >= 0) {
      messages[index] = mapped;
    }
  }

  void _markMessageFailed(String? clientMsgID) {
    if (clientMsgID == null || clientMsgID.isEmpty) return;

    final index = messages.indexWhere((item) => item.clientMsgID == clientMsgID);
    if (index < 0) return;
    final old = messages[index];
    messages[index] = ChatMessageModel(
      clientMsgID: old.clientMsgID,
      sendID: old.sendID,
      recvID: old.recvID,
      content: old.content,
      sendTime: old.sendTime,
      isSelf: old.isSelf,
      isSendFailed: true,
    );
  }
}
