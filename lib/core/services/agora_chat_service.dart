import 'package:dtd/core/utils/log_util.dart';
import 'package:dtd/data/repositories/agora_chat_repository.dart';
import 'package:get/get.dart';
import 'package:shengwang_chat_uikit/chat_uikit.dart';

class AgoraChatService extends GetxService {
  static const String TAG = 'AgoraChatService';

  static AgoraChatService get to => Get.find();

  String? _appKey;
  Future<void>? _loginFuture;
  final AgoraChatRepository _agoraChatRepository = AgoraChatRepository();

  Future<void> initialize({required String appKey}) async {
    if (_appKey == appKey) return;

    LogUtil.d('声网聊天初始化: $appKey', tag: TAG);
    try {
      await ChatUIKit.instance.init(
        options: Options.withAppId(appKey, autoLogin: false),
      );
      _appKey = appKey;
      LogUtil.d('声网聊天初始化成功', tag: TAG);
    } catch (e) {
      LogUtil.d('声网聊天初始化失败: $e', tag: TAG);
      rethrow;
    }
  }

  Future<void> login(
    String userId,
    String token, {
    String? nickname,
    String? avatarUrl,
  }) async {
    if (_loginFuture != null) {
      return _loginFuture;
    }
    _loginFuture = _doLogin(
      userId,
      token,
      nickname: nickname,
      avatarUrl: avatarUrl,
    );
    try {
      await _loginFuture;
    } finally {
      _loginFuture = null;
    }
  }

  Future<void> _doLogin(
    String userId,
    String token, {
    String? nickname,
    String? avatarUrl,
  }) async {
    LogUtil.d('声网聊天登录: $userId', tag: TAG);
    try {
      final currentUserId = ChatUIKit.instance.currentUserId;
      if (currentUserId == userId) {
        await refreshUserProfiles();
        LogUtil.d('声网聊天已登录: $userId', tag: TAG);
        return;
      }
      if (currentUserId != null && currentUserId.isNotEmpty) {
        LogUtil.d('声网聊天切换用户: $currentUserId -> $userId', tag: TAG);
        await ChatUIKit.instance.logout();
      }
      await ChatUIKit.instance
          .loginWithToken(userId: userId, token: token)
          .timeout(const Duration(seconds: 15));
      await refreshUserProfiles();
      LogUtil.d('声网聊天登录成功: $userId', tag: TAG);
    } catch (e) {
      LogUtil.d('声网聊天登录失败: $e', tag: TAG);
      rethrow;
    }
  }

  Future<void> refreshUserProfiles() async {
    List<Conversation> conversations = await ChatUIKit.instance.getAllConversations();
    String? currentUserId = ChatUIKit.instance.currentUserId;
    List<String> userIds = [];
    if (currentUserId != null) {
      userIds.add(currentUserId);
    }
    LogUtil.d('refreshUserProfiles 会话列表长度: ${conversations.length}.', tag: TAG);
    for (var conv in conversations) {
      String conversationId = conv.id;
      LogUtil.d("refreshUserProfiles 会话ID$conversationId ${conv.type}", tag: TAG);
      if (ChatConversationType.Chat == conv.type) {
        // 单聊：会话 ID 即对方用户 ID
        String peerUserId = conversationId;
        userIds.add(peerUserId);
        LogUtil.d("refreshUserProfiles 对方用户ID$peerUserId", tag: TAG);
      } else if (ChatConversationType.GroupChat == conv.type) {
        // 群聊：会话 ID 是群组 ID
        String groupId = conversationId;
        LogUtil.d("refreshUserProfiles 群组ID$groupId", tag: TAG);
      }
    }
    final normalizedIds =
        userIds.map(_parseBusinessUserId).nonNulls.toSet().toList();
    if (normalizedIds.isEmpty) return;

    try {
      final profiles =
          await _agoraChatRepository.getUserProfiles(normalizedIds);
      if (profiles.isEmpty) return;

      final chatProfiles = <ChatUIKitProfile>[];
      for (final profile in profiles) {
        chatProfiles.add(
            ChatUIKitProfile.contact(
              id: profile.userId.toString(),
              nickname: profile.nickname,
              avatarUrl: profile.avatarUrl,
            ),
          );
      }
      ChatUIKitProvider.instance.addProfiles(chatProfiles);
    } catch (e) {
      LogUtil.d('声网聊天用户信息刷新失败: $e', tag: TAG);
    }
  }

  int? _parseBusinessUserId(String userId) {
    final trimmed = userId.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  Future<void> logout() async {
    LogUtil.d('声网聊天登出', tag: TAG);
    try {
      if (ChatUIKit.instance.currentUserId?.isNotEmpty == true) {
        await ChatUIKit.instance.logout();
      }
    } catch (e) {
      LogUtil.d('声网聊天登出失败: $e', tag: TAG);
    }
  }
}
