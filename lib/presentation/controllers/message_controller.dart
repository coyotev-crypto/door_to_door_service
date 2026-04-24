import 'package:door_to_door_service/core/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import '../../core/services/agora_chat_service.dart';

/// 消息控制器
class MessageController extends GetxController {
  static MessageController get to => Get.find();

  // 声网聊天服务
  final AgoraChatService _chatService = AgoraChatService.to;

  // 当前选中的会话ID
  final RxString currentConversationId = ''.obs;

  // 消息列表
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  // 是否正在加载
  final RxBool isLoading = false.obs;

  // 是否还有更多历史消息
  final RxBool hasMore = true.obs;

  // 输入框文本
  final TextEditingController messageController = TextEditingController();

  // 是否正在发送消息
  final RxBool isSending = false.obs;
  
  // 当前用户ID
  String? get currentUserId => ChatClient.getInstance.currentUserId;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  /// 处理新消息
  void _handleNewMessage(ChatMessage message) {
    // 如果是当前会话的消息，添加到消息列表
    if (message.conversationId == currentConversationId.value) {
      messages.add(message);
      // 滚动到底部
      scrollToBottom();
    }
  }

  /// 选择会话
  void selectConversation(String conversationId) {
    currentConversationId.value = conversationId;
    loadMessages(conversationId);

    // 标记为已读
    _chatService.markConversationAsRead(conversationId);
  }

  /// 加载消息
  Future<void> loadMessages(String conversationId) async {
    try {
      isLoading.value = true;
      messages.clear();

      // 从声网加载消息
      final result = await ChatClient.getInstance.chatManager
          .fetchHistoryMessages(
            conversationId: conversationId,
            pageSize: 20,
            direction: ChatSearchDirection.Up,
          );

      messages.value = result.data.reversed.toList();
      hasMore.value = result.data.length >= 20;

      // 滚动到底部
      scrollToBottom();
    } catch (e) {
      print('加载消息失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载更多历史消息
  Future<void> loadMoreMessages() async {
    if (isLoading.value || !hasMore.value || messages.isEmpty) return;

    try {
      isLoading.value = true;

      final oldestMessage = messages.first;
      final result = await ChatClient.getInstance.chatManager
          .fetchHistoryMessages(
            conversationId: currentConversationId.value,
            pageSize: 20,
            startMsgId: oldestMessage.msgId,
            direction: ChatSearchDirection.Up,
          );

      final newMessages = result.data.reversed.toList();
      messages.insertAll(0, newMessages);
      hasMore.value = result.data.length >= 20;
    } catch (e) {
      print('加载更多消息失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 发送文本消息
  Future<void> sendTextMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty) return;

    try {
      isSending.value = true;

      // 创建消息对象
      final msg = ChatMessage.createTxtSendMessage(
        targetId: currentConversationId.value,
        content: content,
      );

      // 添加到消息列表
      messages.add(msg);

      // 清空输入框
      messageController.clear();

      // 滚动到底部
      scrollToBottom();

      // 发送消息
      await ChatClient.getInstance.chatManager.sendMessage(msg);
    } catch (e) {
      print('发送消息失败: $e');
      ToastUtil.showError('消息发送失败，请重试');
    } finally {
      isSending.value = false;
    }
  }

  /// 滚动到底部
  void scrollToBottom() {
    // 这里需要通过key获取滚动控制器并滚动到底部
    // 实际实现中需要传入滚动控制器
  }

  /// 删除消息
  Future<void> deleteMessage(String messageId) async {
    try {
      // 从本地数据库中删除指定 ID 的消息
      await ChatClient.getInstance.chatManager.deleteRemoteMessagesWithIds(
        conversationId: currentConversationId.value,
        type: ChatConversationType.Chat,
        msgIds: [messageId],
      );
      messages.removeWhere((msg) => msg.msgId == messageId);
    } catch (e) {
      print('删除消息失败: $e');
    }
  }

  /// 撤回消息
  Future<void> recallMessage(String messageId) async {
    try {
      await ChatClient.getInstance.chatManager.recallMessage(messageId);
      // 更新消息状态为已撤回
      final index = messages.indexWhere((msg) => msg.msgId == messageId);
      if (index != -1) {
        // 这里需要创建一个撤回消息的占位符
        // 实际实现中需要根据声网SDK的API调整
      }
    } catch (e) {
      print('撤回消息失败: $e');
    }
  }
}
