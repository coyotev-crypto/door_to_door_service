class AppVersionCheckResult {
  final bool hasUpdate;
  final String? updateType;
  final String? versionName;
  final int? versionCode;
  final String? downloadUrl;
  final int? fileSize;
  final String? md5;
  final String? releaseNotes;
  final String? releaseDate;

  const AppVersionCheckResult({
    required this.hasUpdate,
    this.updateType,
    this.versionName,
    this.versionCode,
    this.downloadUrl,
    this.fileSize,
    this.md5,
    this.releaseNotes,
    this.releaseDate,
  });

  factory AppVersionCheckResult.fromJson(Map<String, dynamic> json) {
    return AppVersionCheckResult(
      hasUpdate: json['has_update'] == true,
      updateType: json['update_type']?.toString(),
      versionName: json['version_name']?.toString(),
      versionCode: _toInt(json['version_code']),
      downloadUrl: json['download_url']?.toString(),
      fileSize: _toInt(json['file_size']),
      md5: json['md5']?.toString(),
      releaseNotes: json['release_notes']?.toString(),
      releaseDate: json['release_date']?.toString(),
    );
  }

  bool get isForceUpdate => updateType == 'force';

  bool get hasDownloadUrl => downloadUrl != null && downloadUrl!.isNotEmpty;

  static const none = AppVersionCheckResult(hasUpdate: false);
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
