import 'package:door_to_door_service/core/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingUtil {
  static bool _isShowing = false;
  static BuildContext? _dialogContext;

  static void show({String? message}) {
    if (_isShowing) return;
    _isShowing = true;
    Get.dialog(
      Builder(
        builder: (ctx) {
          _dialogContext = ctx;
          return PopScope(
            canPop: false,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppTheme.gold,
                      strokeWidth: 2.5,
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(message,
                          style: const TextStyle(
                              fontSize: 14, color: AppTheme.textSecondary)),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
      barrierDismissible: false,
      barrierColor: Colors.black26,
    );
  }

  static void dismiss() {
    if (!_isShowing) return;
    _isShowing = false;
    final ctx = _dialogContext;
    _dialogContext = null;
    if (ctx != null && ctx.mounted) {
      final route = ModalRoute.of(ctx);
      if (route != null) {
        Navigator.of(ctx).removeRoute(route);
      }
    }
  }
}
