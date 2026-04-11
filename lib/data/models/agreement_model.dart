/// 协议模型
class AgreementModel {
  final int id;
  final String type;
  final String version;
  final String title;
  final String content;
  final bool isCurrent;
  final DateTime? createTime;
  final DateTime? updateTime;

  AgreementModel({
    required this.id,
    required this.type,
    required this.version,
    required this.title,
    required this.content,
    required this.isCurrent,
    this.createTime,
    this.updateTime,
  });

  factory AgreementModel.fromJson(Map<String, dynamic> json) {
    return AgreementModel(
      id: json['id'] as int,
      type: json['type'] as String,
      version: json['version'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      isCurrent: json['isCurrent'] as bool,
      createTime: json['createTime'] != null
          ? DateTime.parse(json['createTime'] as String)
          : null,
      updateTime: json['updateTime'] != null
          ? DateTime.parse(json['updateTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'version': version,
      'title': title,
      'content': content,
      'isCurrent': isCurrent,
      'createTime': createTime?.toIso8601String(),
      'updateTime': updateTime?.toIso8601String(),
    };
  }
}
