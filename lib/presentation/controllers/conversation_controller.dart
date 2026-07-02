import 'dart:async';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';

import '../../core/services/chat_user_profile_service.dart';
import '../../core/services/openim_chat_service.dart';
import '../../core/utils/log_util.dart';
import '../../data/models/chat_conversation_model.dart';
import '../../routes/route_names.dart';

class ConversationController extends GetxController {
  static const String tag = 'ConversationController';

  final OpenIMChatService _chatService = Get.isRegistered<OpenIMChatService>()
      ? OpenIMChatService.to
      : Get.put(OpenIMChatService(), permanent: true);
  final ChatUserProfileService _userProfileService =
      Get.isRegistered<ChatUserProfileService>()
          ? ChatUserProfileService.to
          : Get.put(ChatUserProfileService(), permanent: true);

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
      final mapped =
          list.map(_mapConversation).whereType<ChatConversationModel>().toList();
      conversations.assignAll(await _applyUserProfiles(mapped));
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
    final changedUserIDs = <String>[];
    for (final changed in changedList) {
      final mapped = _mapConversation(changed);
      if (mapped == null) continue;

      conversations.removeWhere(
        (item) => item.conversationID == mapped.conversationID,
      );
      conversations.insert(0, mapped);
      changedUserIDs.add(mapped.userID);
    }
    _sort();
    _refreshUserProfiles(changedUserIDs);
  }

  void _sort() {
    conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  ChatConversationModel? _mapConversation(ConversationInfo conversation) {
    final userID = conversation.userID ?? '';
    if (userID.isEmpty) return null;

    final latestMessage = conversation.latestMsg;
    final timestamp =
        latestMessage?.sendTime ?? conversation.latestMsgSendTime ?? 0;
    return ChatConversationModel(
      conversationID: conversation.conversationID,
      userID: userID,
      title: _profileName(userID) ?? _notEmpty(conversation.showName) ?? userID,
      faceURL: _profileAvatar(userID) ?? _notEmpty(conversation.faceURL),
      lastMessage: _messagePreview(latestMessage),
      timeText: _formatTimeline(timestamp),
      unreadCount: conversation.unreadCount,
      timestamp: timestamp,
    );
  }

  Future<List<ChatConversationModel>> _applyUserProfiles(
    List<ChatConversationModel> list,
  ) async {
    await _userProfileService.getProfilesForOpenIMUserIDs(
      list.map((item) => item.userID),
    );
    return list.map(_applyCachedProfile).toList();
  }

  Future<void> _refreshUserProfiles(List<String> userIDs) async {
    if (userIDs.isEmpty) return;
    await _userProfileService.getProfilesForOpenIMUserIDs(userIDs);
    for (var i = 0; i < conversations.length; i++) {
      conversations[i] = _applyCachedProfile(conversations[i]);
    }
  }

  ChatConversationModel _applyCachedProfile(ChatConversationModel conversation) {
    final profile = _userProfileService.profileForOpenIMUserID(
      conversation.userID,
    );
    if (profile == null) return conversation;

    final nickname = _notEmpty(profile.nickname);
    final avatarUrl = _notEmpty(profile.avatarUrl);
    return conversation.copyWith(
      title: nickname ?? conversation.title,
      faceURL: avatarUrl ?? conversation.faceURL,
    );
  }

  String? _profileName(String userID) {
    return _notEmpty(
      _userProfileService.profileForOpenIMUserID(userID)?.nickname,
    );
  }

  String? _profileAvatar(String userID) {
    return _notEmpty(
      _userProfileService.profileForOpenIMUserID(userID)?.avatarUrl,
    );
  }

  String _messagePreview(Message? message) {
    if (message == null) return '';
    return message.textElem?.content ?? '[暂不支持的消息]';
  }

  String _formatTimeline(int timestamp) {
    if (timestamp <= 0) return '';

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(date.year, date.month, date.day);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    if (messageDay == today) {
      return '$hour:$minute';
    }
    if (messageDay == today.subtract(const Duration(days: 1))) {
      return '昨天';
    }
    if (date.year == now.year) {
      return '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    }
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String? _notEmpty(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
