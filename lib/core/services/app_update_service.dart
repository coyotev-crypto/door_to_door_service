import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/app_version_model.dart';
import '../../data/repositories/app_version_repository.dart';
import '../network/dio_client.dart';
import '../utils/log_util.dart';
import '../utils/toast_util.dart';
import 'auth_service.dart';

enum AppUpdateDownloadState { idle, downloading, failed, completed }

class AppUpdateService extends GetxService {
  static const _channel = 'official';
  static const _lastCheckAtKey = 'app_update.last_check_at';
  static const _deviceIdKey = 'app_update.device_id';
  static const _ignoredVersionKey = 'app_update.ignored_version';
  static const _ignoredDateKey = 'app_update.ignored_date';
  static const _autoCheckInterval = Duration(hours: 6);

  final AppVersionRepository _repository = AppVersionRepository();

  final Rxn<AppVersionCheckResult> updateResult =
      Rxn<AppVersionCheckResult>();
  final Rx<AppUpdateDownloadState> downloadState =
      AppUpdateDownloadState.idle.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final RxString errorMessage = ''.obs;
  final RxString apkPath = ''.obs;

  bool _checking = false;

  static AppUpdateService get instance {
    if (Get.isRegistered<AppUpdateService>()) {
      return Get.find<AppUpdateService>();
    }
    return Get.put(AppUpdateService(), permanent: true);
  }

  Future<AppVersionCheckResult?> checkForUpdate({
    bool manual = false,
    bool showNoUpdateToast = false,
  }) async {
    if (_checking) return updateResult.value;
    if (!Platform.isAndroid) {
      if (showNoUpdateToast) ToastUtil.showMessage('当前平台暂无更新');
      return AppVersionCheckResult.none;
    }

    final prefs = await SharedPreferences.getInstance();
    if (!manual && !_shouldAutoCheck(prefs)) return null;

    _checking = true;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;
      final result = await _repository.checkVersion(
        currentVersion: packageInfo.version,
        currentVersionCode: currentVersionCode,
        platform: 'android',
        deviceId: await _deviceId(prefs),
        userId: AuthService.instance.user?.id,
        channel: _channel,
      );
      await prefs.setInt(
        _lastCheckAtKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      if (!result.hasUpdate) {
        updateResult.value = null;
        if (showNoUpdateToast) ToastUtil.showSuccess('当前已是最新版本');
        return result;
      }
      if (!manual && _isIgnoredToday(prefs, result)) return null;

      updateResult.value = result;
      downloadState.value = AppUpdateDownloadState.idle;
      downloadProgress.value = 0;
      errorMessage.value = '';
      apkPath.value = '';
      return result;
    } catch (e) {
      LogUtil.w('版本检查失败: $e', tag: 'AppUpdateService');
      if (showNoUpdateToast) ToastUtil.showError('检查更新失败');
      return null;
    } finally {
      _checking = false;
    }
  }

  Future<void> ignoreSuggestedUpdate(AppVersionCheckResult result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ignoredVersionKey, result.versionName ?? '');
    await prefs.setString(_ignoredDateKey, _dateKey(DateTime.now()));
  }

  Future<void> downloadAndInstall(AppVersionCheckResult result) async {
    if (!result.hasDownloadUrl) {
      errorMessage.value = '下载地址为空';
      downloadState.value = AppUpdateDownloadState.failed;
      return;
    }

    downloadState.value = AppUpdateDownloadState.downloading;
    downloadProgress.value = 0;
    errorMessage.value = '';
    try {
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}${Platform.pathSeparator}door_to_door_${result.versionName ?? result.versionCode ?? 'latest'}.apk',
      );
      if (file.existsSync()) {
        await file.delete();
      }

      await DioClient.instance.download(
        result.downloadUrl!,
        file.path,
        onReceiveProgress: (received, total) {
          if (total <= 0) return;
          downloadProgress.value = (received / total).clamp(0.0, 1.0);
        },
      );

      await _validateDownloadedFile(file, result);
      apkPath.value = file.path;
      downloadProgress.value = 1;
      downloadState.value = AppUpdateDownloadState.completed;
      await OpenFilex.open(file.path);
    } catch (e) {
      errorMessage.value = '下载失败，请检查网络后重试';
      downloadState.value = AppUpdateDownloadState.failed;
      LogUtil.e('下载更新失败: $e', tag: 'AppUpdateService');
    }
  }

  Future<void> installDownloadedApk() async {
    if (apkPath.value.isEmpty) return;
    await OpenFilex.open(apkPath.value);
  }

  void exitApp() {
    SystemNavigator.pop();
  }

  bool _shouldAutoCheck(SharedPreferences prefs) {
    final last = prefs.getInt(_lastCheckAtKey);
    if (last == null) return true;
    final lastCheck = DateTime.fromMillisecondsSinceEpoch(last);
    return DateTime.now().difference(lastCheck) >= _autoCheckInterval;
  }

  bool _isIgnoredToday(
    SharedPreferences prefs,
    AppVersionCheckResult result,
  ) {
    return prefs.getString(_ignoredVersionKey) == result.versionName &&
        prefs.getString(_ignoredDateKey) == _dateKey(DateTime.now());
  }

  Future<String> _deviceId(SharedPreferences prefs) async {
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = const Uuid().v4();
    await prefs.setString(_deviceIdKey, id);
    return id;
  }

  Future<void> _validateDownloadedFile(
    File file,
    AppVersionCheckResult result,
  ) async {
    if (result.fileSize != null && result.fileSize! > 0) {
      final actualSize = await file.length();
      if (actualSize != result.fileSize) {
        await file.delete();
        throw Exception('安装包大小校验失败');
      }
    }
    if (result.md5 != null && result.md5!.isNotEmpty) {
      final digest = md5.convert(await file.readAsBytes()).toString();
      if (digest.toLowerCase() != result.md5!.toLowerCase()) {
        await file.delete();
        throw Exception('安装包MD5校验失败');
      }
    }
  }

  String _dateKey(DateTime value) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }
}
