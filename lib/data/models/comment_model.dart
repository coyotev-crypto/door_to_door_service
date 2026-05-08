/// 评论模型
class CommentModel {
  final int id;
  final int postId;
  final int? parentId;
  final int userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final int likeCount;
  final bool isLiked;
  final List<CommentModel> replies;
  final String createTime;

  CommentModel({
    required this.id,
    required this.postId,
    this.parentId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    this.likeCount = 0,
    this.isLiked = false,
    this.replies = const [],
    required this.createTime,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] is String ? int.parse(json['id']) : (json['id'] as int? ?? 0),
      postId: json['postId'] is String
          ? int.parse(json['postId'])
          : (json['postId'] as int? ?? 0),
      parentId: json['parentId'] is String
          ? int.tryParse(json['parentId'])
          : json['parentId'] as int?,
      userId: json['userId'] is String
          ? int.parse(json['userId'])
          : (json['userId'] as int? ?? 0),
      userName: json['userName'] as String? ?? '',
      userAvatar: json['userAvatar'] as String?,
      content: json['content'] as String? ?? '',
      likeCount: json['likeCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createTime: json['createTime'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'parentId': parentId,
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'content': content,
        'likeCount': likeCount,
        'isLiked': isLiked,
        'replies': replies.map((e) => e.toJson()).toList(),
        'createTime': createTime,
      };
}
