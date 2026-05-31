import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:door_to_door_service/core/utils/log_util.dart';
import 'package:get/get.dart';

/// 声网消息服务
class AgoraChatService extends GetxService {
  static const String TAG = 'AgoraChatService';
  static AgoraChatService get to => Get.find();

  // 声网聊天客户端
  late ChatClient chatClient;

  // 连接状态
  final RxBool isConnected = false.obs;

  // 未读消息数量
  final RxInt unreadCount = 0.obs;

  // 会话列表
  final RxList<ChatConversation> conversations = <ChatConversation>[].obs;

  /// 初始化声网聊天（由外部调用，传入真实 AppKey）
  Future<void> initialize({required String appKey}) async {
    try {
      final options = ChatOptions(
        appKey: appKey,
        autoLogin: false,
      );

      await ChatClient.getInstance.init(options);

      chatClient = ChatClient.getInstance;

      ChatClient.getInstance.chatManager.addEventHandler(
        'UNIQUE_HANDLER_ID',
        ChatEventHandler(onMessagesReceived: _handleMessagesReceived),
      );

      LogUtil.d('声网聊天初始化成功', tag: TAG);
    } catch (e) {
      LogUtil.d('声网聊天初始化失败: $e', tag: TAG);
    }
  }

  /// 登录
  Future<void> login(String userId, String token) async {
    try {
      await ChatClient.getInstance.loginWithToken(userId, token);
      isConnected.value = true;
      LogUtil.d('声网聊天登录成功: $userId', tag: TAG);

      // 加载会话列表
      _loadConversations();
    } catch (e) {
      LogUtil.d('声网聊天登录失败: $e', tag: TAG);
      isConnected.value = false;
      rethrow;
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      await ChatClient.getInstance.logout(true);
      isConnected.value = false;
      conversations.clear();
      unreadCount.value = 0;
      LogUtil.d('声网聊天登出成功', tag: TAG);
    } catch (e) {
      LogUtil.d('声网聊天登出失败: $e', tag: TAG);
      rethrow;
    }
  }

  /// 发送文本消息
  Future<void> sendTextMessage(String toUserId, String content) async {
    try {
      final msg = ChatMessage.createTxtSendMessage(
        targetId: toUserId,
        content: content,
      );

      await ChatClient.getInstance.chatManager.sendMessage(msg);
      LogUtil.d('发送文本消息成功: $content', tag: TAG);
    } catch (e) {
      LogUtil.d('发送文本消息失败: $e', tag: TAG);
      rethrow;
    }
  }

  /// 加载会话列表
  Future<void> _loadConversations() async {
    try {
      conversations.value = await ChatClient.getInstance.chatManager.loadAllConversations();

      // 计算未读消息数量
      int totalUnread = 0;
      for (var conversation in conversations) {
        totalUnread += await conversation.unreadCount();
      }
      unreadCount.value = totalUnread;

      LogUtil.d('加载会话列表成功: ${conversations.length}', tag: TAG);
    } catch (e) {
      LogUtil.d('加载会话列表失败: $e', tag: TAG);
    }
  }

  /// 处理收到的新消息
  void _handleMessagesReceived(List<ChatMessage> messages) {
    for (var message in messages) {
      LogUtil.d('收到新消息: ${message.body}', tag: TAG);

      // 更新未读数量
      unreadCount.value++;
    }

    // 重新加载会话列表
    _loadConversations();
  }

  /// 处理新会话
  void _handleNewConversations(List<ChatConversation> newConversations) {
    for (var conversation in newConversations) {
      // 检查是否已存在
      if (!conversations.any((c) => c.id == conversation.id)) {
        conversations.add(conversation);
      }
    }
    conversations.refresh();
  }

  /// 处理会话更新
  void _handleConversationsUpdate(List<ChatConversation> updatedConversations) {
    for (var updatedConv in updatedConversations) {
      final index = conversations.indexWhere((c) => c.id == updatedConv.id);
      if (index != -1) {
        conversations[index] = updatedConv;
      }
    }
    conversations.refresh();

    // 重新计算未读数量
    _updateUnreadCount();
  }

  /// 更新未读数量
  Future<void> _updateUnreadCount() async {
    int totalUnread = 0;
    for (var conversation in conversations) {
      totalUnread += await conversation.unreadCount();
    }
    unreadCount.value = totalUnread;
  }

  /// 标记会话为已读
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      await ChatClient.getInstance.chatManager.sendConversationReadAck(conversationId);
      _loadConversations();
    } catch (e) {
      LogUtil.d('标记会话为已读失败: $e', tag: TAG);
    }
  }

  /// 删除会话
  Future<void> deleteConversation(String conversationId) async {
    try {
      await ChatClient.getInstance.chatManager.deleteConversation(conversationId);
      conversations.removeWhere((c) => c.id == conversationId);
      conversations.refresh();
      _updateUnreadCount();
    } catch (e) {
      LogUtil.d('删除会话失败: $e', tag: TAG);
    }
  }
}
