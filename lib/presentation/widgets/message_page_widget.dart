import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/screen_adapter.dart';
import '../../core/services/agora_chat_service.dart';
import '../controllers/message_controller.dart';
import '../screens/chat_detail_screen.dart';

/// 消息页面组件
class MessagePageWidget extends StatefulWidget {
  const MessagePageWidget({super.key});

  @override
  State<MessagePageWidget> createState() => _MessagePageWidgetState();
}

class _MessagePageWidgetState extends State<MessagePageWidget> {
  final AgoraChatService _chatService = AgoraChatService.to;
  final MessageController _messageController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '消息',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          // 添加联系人按钮
          IconButton(
            icon: Icon(Icons.person_add, size: 24.sp, color: Colors.black87),
            onPressed: () {
              // TODO: 打开添加联系人页面
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_chatService.conversations.isEmpty) {
          return _buildEmptyState();
        }
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: _chatService.conversations.length,
          itemBuilder: (context, index) {
            return _buildConversationItem(
              _chatService.conversations[index],
            );
          },
        );
      }),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80.sp,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无消息',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '开始与服务人员聊天吧',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建会话项
  Widget _buildConversationItem(ChatConversation conversation) {
    return FutureBuilder<int>(
      future: conversation.unreadCount(),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return GestureDetector(
          onTap: () {
            // 打开聊天详情
            _openChatDetail(conversation);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[100]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                // 头像
                _buildAvatar(conversation),
                SizedBox(width: 12.w),
                // 内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 昵称和时间
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            conversation.id,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          FutureBuilder<ChatMessage?>(
                            future: conversation.latestMessage(),
                            builder: (context, messageSnapshot) {
                              return Text(
                                _formatTime(messageSnapshot.data?.localTime),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[500],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      // 最后消息和未读数
                      Row(
                        children: [
                          Expanded(
                            child: FutureBuilder<ChatMessage?>(
                              future: conversation.latestMessage(),
                              builder: (context, messageSnapshot) {
                                return Text(
                                  _getLastMessageText(messageSnapshot.data),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建头像
  Widget _buildAvatar(ChatConversation conversation) {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
      ),
      child: _buildDefaultAvatar(conversation.id),
    );
  }

  /// 构建默认头像
  Widget _buildDefaultAvatar(String? name) {
    return Center(
      child: Text(
        name?.substring(0, 1).toUpperCase() ?? '?',
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  /// 格式化时间
  String _formatTime(int? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final messageTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    final difference = now.difference(messageTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${messageTime.month}月${messageTime.day}日';
    }
  }

  /// 获取最后一条消息文本
  String _getLastMessageText(ChatMessage? message) {
    if (message == null) return '';

    switch (message.body.type) {
      case MessageType.TXT:
        final textBody = message.body as ChatTextMessageBody;
        return textBody.content;
      case MessageType.IMAGE:
        return '[图片]';
      case MessageType.VIDEO:
        return '[视频]';
      case MessageType.VOICE:
        return '[语音]';
      case MessageType.LOCATION:
        return '[位置]';
      case MessageType.FILE:
        return '[文件]';
      default:
        return '[未知消息]';
    }
  }

  /// 打开聊天详情
  void _openChatDetail(ChatConversation conversation) {
    _messageController.selectConversation(conversation.id);

    // 导航到聊天详情页面
    Get.to(() => ChatDetailScreen(
          conversationId: conversation.id,
          userName: conversation.id,
          userAvatar: null,
        ));
  }
}
