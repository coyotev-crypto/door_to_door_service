import 'package:dtd/core/themes/app_theme.dart';
import 'package:dtd/presentation/app.dart';
import 'package:flutter/material.dart';

class LoadingUtil {
  static bool _isShowing = false;
  static OverlayEntry? _overlayEntry;

  static void show({String? message}) {
    if (_isShowing) return;
    final overlayState = MyApp.overlayKey.currentState;
    if (overlayState == null) return;
    _isShowing = true;

    final entry = OverlayEntry(
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: PopScope(
          canPop: false,
          child: Container(
            color: Colors.black26,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
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
          ),
        ),
      ),
    );

    _overlayEntry = entry;
    overlayState.insert(entry);
  }

  static void dismiss() {
    if (!_isShowing) return;
    _isShowing = false;
    final entry = _overlayEntry;
    _overlayEntry = null;
    if (entry != null && entry.mounted) {
      entry.remove();
    }
  }
}
