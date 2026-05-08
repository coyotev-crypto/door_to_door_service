/// 帖子模型
class PostModel {
  final int id;
  final String title;
  final String content;
  final List<String> images;
  final List<String> tags;
  final int authorId;
  final String authorName;
  final String? authorAvatar;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isCollected;
  final String createTime;
  final String? updateTime;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    this.images = const [],
    this.tags = const [],
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isCollected = false,
    required this.createTime,
    this.updateTime,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] is String ? int.parse(json['id']) : (json['id'] as int? ?? 0),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      authorId: json['authorId'] is String
          ? int.parse(json['authorId'])
          : (json['authorId'] as int? ?? 0),
      authorName: json['authorName'] as String? ?? '',
      authorAvatar: json['authorAvatar'] as String?,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isCollected: json['isCollected'] as bool? ?? false,
      createTime: json['createTime'] as String? ?? '',
      updateTime: json['updateTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'images': images,
        'tags': tags,
        'authorId': authorId,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'likeCount': likeCount,
        'commentCount': commentCount,
        'isLiked': isLiked,
        'isCollected': isCollected,
        'createTime': createTime,
        'updateTime': updateTime,
      };

  PostModel copyWith({
    int? id,
    String? title,
    String? content,
    List<String>? images,
    List<String>? tags,
    int? authorId,
    String? authorName,
    String? authorAvatar,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    bool? isCollected,
    String? createTime,
    String? updateTime,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      isCollected: isCollected ?? this.isCollected,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }
}
