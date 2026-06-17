import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class UserAvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final String? username;
  final double size;

  const UserAvatarWidget({
    super.key,
    this.avatarUrl,
    this.username,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl?.trim().isNotEmpty == true;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.creamBg,
        border:
            Border.all(color: AppTheme.gold.withValues(alpha: 0.25), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: hasAvatar
          ? Image.network(
              avatarUrl!.trim(),
              fit: BoxFit.cover,
              cacheWidth: 256,
              errorBuilder: (_, __, ___) => _avatarPlaceholder(),
            )
          : _avatarPlaceholder(),
    );
  }

  Widget _avatarPlaceholder() {
    final displayName = username?.trim();
    final firstLetter =
        displayName?.isNotEmpty == true ? displayName![0] : null;

    if (firstLetter == null) {
      return Icon(Icons.person_rounded,
          size: size * 0.5, color: AppTheme.textMuted);
    }

    return Center(
      child: Text(
        firstLetter,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
          color: AppTheme.gold,
        ),
      ),
    );
  }
}
