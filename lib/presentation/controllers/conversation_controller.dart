import 'dart:async';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';

import '../../core/services/openim_chat_service.dart';
import '../../core/utils/log_util.dart';
import '../../data/models/chat_conversation_model.dart';
import '../../routes/route_names.dart';

class ConversationController extends GetxController {
  static const String tag = 'ConversationController';

  final OpenIMChatService _chatService = Get.isRegistered<OpenIMChatService>()
      ? OpenIMChatService.to
      : Get.put(OpenIMChatService(), permanent: true);

  final RxList<ChatConversationModel> conversations =
      <ChatConversationModel>[].obs;
  final RxBool isLoading = false.obs;

  StreamSubscription<List<ConversationInfo>>? _conversationSub;

  @override
  void onInit() {
    super.onInit();
    _conversationSub = _chatService.conversationChanged.listen(_mergeConversations);
    loadFirstPage();
  }

  @override
  void onClose() {
    _conversationSub?.cancel();
    super.onClose();
  }

  Future<void> loadFirstPage() async {
    isLoading.value = true;
    try {
      await _chatService.ensureLoggedIn();
      final list =
          await OpenIM.iMManager.conversationManager.getConversationListSplit(
        offset: 0,
        count: 100,
      );
      conversations.assignAll(
        list.map(_mapConversation).whereType<ChatConversationModel>(),
      );
      _sort();
    } catch (e) {
      LogUtil.e('Load conversations failed: $e', tag: tag);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toChat(ChatConversationModel conversation) async {
    await _chatService.ensureLoggedIn();
    Get.toNamed(
      RouteNames.chatDetail,
      parameters: {'userId': conversation.userID},
      arguments: {'conversationID': conversation.conversationID},
    );
  }

  void _mergeConversations(List<ConversationInfo> changedList) {
    for (final changed in changedList) {
      final mapped = _mapConversation(changed);
      if (mapped == null) continue;

      conversations.removeWhere(
        (item) => item.conversationID == mapped.conversationID,
      );
      conversations.insert(0, mapped);
    }
    _sort();
  }

  void _sort() {
    conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  ChatConversationModel? _mapConversation(ConversationInfo conversation) {
    final userID = conversation.userID ?? '';
    if (userID.isEmpty) return null;

    final latestMessage = conversation.latestMsg;
    return ChatConversationModel(
      conversationID: conversation.conversationID,
      userID: userID,
      title: _notEmpty(conversation.showName) ?? userID,
      faceURL: _notEmpty(conversation.faceURL),
      lastMessage: _messagePreview(latestMessage),
      unreadCount: conversation.unreadCount,
      timestamp: latestMessage?.sendTime ?? conversation.latestMsgSendTime ?? 0,
    );
  }

  String _messagePreview(Message? message) {
    if (message == null) return '';
    return message.textElem?.content ?? '[暂不支持的消息]';
  }

  String? _notEmpty(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
