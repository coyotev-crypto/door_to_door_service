import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/screen_adapter.dart';
import '../../controllers/message_controller.dart';

/// 聊天详情页面组件
class ChatDetailWidget extends StatefulWidget {
  final String conversationId;
  final String? userName;
  final String? userAvatar;

  const ChatDetailWidget({
    super.key,
    required this.conversationId,
    this.userName,
    this.userAvatar,
  });

  @override
  State<ChatDetailWidget> createState() => _ChatDetailWidgetState();
}

class _ChatDetailWidgetState extends State<ChatDetailWidget> {
  final MessageController _controller = Get.find();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 加载消息
    _controller.selectConversation(widget.conversationId);

    // 监听滚动，用于加载更多历史消息
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 滚动监听
  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.minScrollExtent) {
      // 滚动到顶部，加载更多历史消息
      _controller.loadMoreMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.userName ?? '聊天',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          // 更多选项
          IconButton(
            icon: Icon(Icons.more_horiz, size: 24.sp, color: Colors.black87),
            onPressed: () {
              // TODO: 显示更多选项
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value && _controller.messages.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: _controller.messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageItem(_controller.messages[index]);
                },
              );
            }),
          ),
          // 输入框
          _buildInputBar(),
        ],
      ),
    );
  }

  /// 构建消息项
  Widget _buildMessageItem(ChatMessage message) {
    final currentUserId = ChatClient.getInstance.currentUserId;
    final isSelf = message.from == currentUserId;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment:
            isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSelf) ...[
            // 对方头像
            _buildAvatar(widget.userAvatar),
            SizedBox(width: 8.w),
          ],
          // 消息内容
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isSelf ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // 消息时间
                Text(
                  _formatTime(message.localTime),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 4.h),
                // 消息气泡
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelf ? Theme.of(context).primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: _buildMessageContent(message),
                ),
              ],
            ),
          ),
          if (isSelf) ...[
            SizedBox(width: 8.w),
            // 自己头像
            _buildAvatar(null),
          ],
        ],
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar(String? avatarUrl) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: avatarUrl != null
          ? ClipOval(
              child: Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar();
                },
              ),
            )
          : _buildDefaultAvatar(),
    );
  }

  /// 构建默认头像
  Widget _buildDefaultAvatar() {
    return Center(
      child: Icon(
        Icons.person,
        size: 20.sp,
        color: Colors.grey[600],
      ),
    );
  }

  /// 构建消息内容
  Widget _buildMessageContent(ChatMessage message) {
    final currentUserId = ChatClient.getInstance.currentUserId;
    final isSelf = message.from == currentUserId;

    switch (message.body.type) {
      case MessageType.TXT:
        final textBody = message.body as ChatTextMessageBody;
        return Text(
          textBody.content,
          style: TextStyle(
            fontSize: 15.sp,
            color: isSelf ? Colors.white : Colors.black87,
            height: 1.4,
          ),
        );
      case MessageType.IMAGE:
        final imageBody = message.body as ChatImageMessageBody;
        return _buildImageMessage(imageBody.remotePath ?? imageBody.localPath);
      case MessageType.VOICE:
        final voiceBody = message.body as ChatVoiceMessageBody;
        return _buildVoiceMessage(
            voiceBody.remotePath ?? voiceBody.localPath, isSelf);
      default:
        return Text(
          '[暂不支持此消息类型]',
          style: TextStyle(
            fontSize: 14.sp,
            color: isSelf ? Colors.white : Colors.black87,
          ),
        );
    }
  }

  /// 构建图片消息
  Widget _buildImageMessage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4.r),
      child: Image.network(
        imageUrl,
        width: 150.w,
        height: 150.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 150.w,
            height: 150.w,
            color: Colors.grey[200],
            child: Icon(
              Icons.broken_image,
              size: 30.sp,
              color: Colors.grey[400],
            ),
          );
        },
      ),
    );
  }

  /// 构建语音消息
  Widget _buildVoiceMessage(String voiceUrl, bool isSelf) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.play_arrow,
          size: 20.sp,
          color: isSelf ? Colors.white : Colors.black87,
        ),
        SizedBox(width: 8.w),
        Container(
          width: 60.w,
          height: 3.h,
          decoration: BoxDecoration(
            color: isSelf ? Colors.white.withValues(alpha: 0.5) : Colors.grey[400],
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ],
    );
  }

  /// 构建输入框
  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 语音按钮
            IconButton(
              icon: Icon(Icons.mic, size: 24.sp, color: Colors.grey[600]),
              onPressed: () {
                // TODO: 实现语音输入
              },
            ),
            // 输入框
            Expanded(
              child: TextField(
                controller: _controller.messageController,
                focusNode: _focusNode,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: '请输入消息...',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                ),
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.black87,
                ),
              ),
            ),
            // 表情按钮
            IconButton(
              icon: Icon(Icons.emoji_emotions_outlined,
                  size: 24.sp, color: Colors.grey[600]),
              onPressed: () {
                // TODO: 实现表情选择
              },
            ),
            // 图片按钮
            IconButton(
              icon: Icon(Icons.image, size: 24.sp, color: Colors.grey[600]),
              onPressed: () {
                // TODO: 实现图片选择
              },
            ),
            // 发送按钮
            Obx(() {
              if (_controller.isSending.value) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              return IconButton(
                icon: Icon(Icons.send,
                    size: 24.sp, color: Theme.of(context).primaryColor),
                onPressed: () {
                  _controller.sendTextMessage();
                  // 收起键盘
                  _focusNode.unfocus();
                },
              );
            }),
          ],
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
      return '${difference.inHours}:${(messageTime.minute).toString().padLeft(2, '0')}';
    } else if (difference.inDays < 2) {
      return '昨天 ${messageTime.hour}:${(messageTime.minute).toString().padLeft(2, '0')}';
    } else {
      return '${messageTime.month}月${messageTime.day}日 ${messageTime.hour}:${(messageTime.minute).toString().padLeft(2, '0')}';
    }
  }
}
