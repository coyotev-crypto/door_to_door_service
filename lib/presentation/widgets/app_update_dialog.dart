import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/app_update_service.dart';
import '../../core/themes/app_theme.dart';
import '../../core/utils/screen_adapter.dart';
import '../../data/models/app_version_model.dart';
import 'primary_button.dart';

class AppUpdateDialog extends StatelessWidget {
  final AppVersionCheckResult result;
  final AppUpdateService service;

  const AppUpdateDialog({
    super.key,
    required this.result,
    required this.service,
  });

  static Future<void> show(AppVersionCheckResult result) {
    return Get.dialog<void>(
      AppUpdateDialog(
        result: result,
        service: AppUpdateService.instance,
      ),
      barrierDismissible: !result.isForceUpdate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final force = result.isForceUpdate;
    final accent = force ? AppTheme.danger : AppTheme.gold;

    return PopScope(
      canPop: !force,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        backgroundColor: Colors.white,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.72,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(result: result, accent: accent),
                SizedBox(height: 16.h),
                _VersionMeta(result: result),
                SizedBox(height: 16.h),
                _ReleaseNotes(notes: result.releaseNotes),
                SizedBox(height: 16.h),
                Obx(() => _DownloadStatus(service: service)),
                SizedBox(height: 16.h),
                Obx(() => _Actions(result: result, service: service)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppVersionCheckResult result;
  final Color accent;

  const _Header({required this.result, required this.accent});

  @override
  Widget build(BuildContext context) {
    final force = result.isForceUpdate;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            force
                ? Icons.security_update_warning_rounded
                : Icons.system_update_rounded,
            color: accent,
            size: 24.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      force ? '需要更新后继续使用' : '发现新版本',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  if (force)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '强制更新',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.danger,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                force ? '当前版本已不再支持，请先完成升级' : '建议更新后体验最新功能',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VersionMeta extends StatelessWidget {
  final AppVersionCheckResult result;

  const _VersionMeta({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.creamBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.warmBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '新版本 ${result.versionName ?? '-'}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Text(
                _fileSize(result.fileSize),
                style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted),
              ),
            ],
          ),
          if (result.releaseDate?.isNotEmpty == true) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.event_rounded,
                    size: 14.sp, color: AppTheme.textMuted),
                SizedBox(width: 6.w),
                Text(
                  '发布于 ${result.releaseDate}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _fileSize(int? bytes) {
    if (bytes == null || bytes <= 0) return '大小未知';
    final mb = bytes / 1024 / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }
}

class _ReleaseNotes extends StatelessWidget {
  final String? notes;

  const _ReleaseNotes({this.notes});

  @override
  Widget build(BuildContext context) {
    final content = notes?.trim().isNotEmpty == true
        ? notes!.trim()
        : '本次更新包含体验优化和问题修复';
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '更新内容',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            constraints: BoxConstraints(maxHeight: 190.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.creamFill,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: SingleChildScrollView(
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.45,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadStatus extends StatelessWidget {
  final AppUpdateService service;

  const _DownloadStatus({required this.service});

  @override
  Widget build(BuildContext context) {
    final state = service.downloadState.value;
    if (state == AppUpdateDownloadState.idle) {
      return const SizedBox.shrink();
    }
    if (state == AppUpdateDownloadState.failed) {
      return Text(
        service.errorMessage.value.isNotEmpty
            ? service.errorMessage.value
            : '下载失败，请检查网络后重试',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppTheme.danger,
        ),
      );
    }

    final progress = service.downloadProgress.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(99.r),
          child: LinearProgressIndicator(
            value: progress <= 0 ? null : progress,
            minHeight: 6.h,
            backgroundColor: AppTheme.warmBorder.withValues(alpha: 0.45),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          state == AppUpdateDownloadState.completed
              ? '安装包已准备好'
              : '下载中 ${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
          style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  final AppVersionCheckResult result;
  final AppUpdateService service;

  const _Actions({required this.result, required this.service});

  @override
  Widget build(BuildContext context) {
    final state = service.downloadState.value;
    final downloading = state == AppUpdateDownloadState.downloading;
    final completed = state == AppUpdateDownloadState.completed;
    final failed = state == AppUpdateDownloadState.failed;

    final primaryText = completed
        ? '立即安装'
        : failed
            ? '重新下载'
            : downloading
                ? '下载中'
                : '立即更新';
    final primaryAction = downloading
        ? null
        : completed
            ? service.installDownloadedApk
            : () => service.downloadAndInstall(result);

    if (result.isForceUpdate) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryButton(
            text: primaryText,
            height: 48.h,
            isLoading: downloading,
            gradientColors: const [AppTheme.gold, AppTheme.amber],
            onPressed: primaryAction,
          ),
          if (failed) ...[
            SizedBox(height: 10.h),
            TextButton(
              onPressed: service.exitApp,
              child: Text(
                '退出应用',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48.h,
            child: OutlinedButton(
              onPressed: downloading
                  ? null
                  : () async {
                      await service.ignoreSuggestedUpdate(result);
                      Get.back();
                    },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.warmBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                foregroundColor: AppTheme.textSecondary,
              ),
              child: const Text('稍后再说'),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: PrimaryButton(
            text: primaryText,
            height: 48.h,
            isLoading: downloading,
            gradientColors: const [AppTheme.gold, AppTheme.amber],
            onPressed: primaryAction,
          ),
        ),
      ],
    );
  }
}
