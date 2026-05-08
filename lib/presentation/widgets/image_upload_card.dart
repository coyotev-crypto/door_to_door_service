import 'package:flutter/material.dart';
import '../../../core/utils/screen_adapter.dart';

/// 通用图片上传卡片组件
class ImageUploadCard extends StatelessWidget {
  /// 标题
  final String title;

  /// 图片URL
  final String? imageUrl;

  /// 点击回调
  final VoidCallback onTap;

  /// 容器高度
  final double? height;

  /// 容器宽度
  final double? width;

  /// 圆角半径
  final double? borderRadius;

  /// 背景颜色
  final Color? backgroundColor;

  /// 边框颜色
  final Color? borderColor;

  /// 是否显示边框
  final bool showBorder;

  /// 上传图标
  final Widget? uploadIcon;

  /// 上传提示文本
  final String? uploadText;

  /// 错误图标
  final Widget? errorIcon;

  const ImageUploadCard({
    super.key,
    required this.title,
    required this.onTap,
    this.imageUrl,
    this.height,
    this.width,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.showBorder = true,
    this.uploadIcon,
    this.uploadText,
    this.errorIcon,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final normalizedImageUrl = _normalizeImageUrl(imageUrl);
    final hasImage = normalizedImageUrl.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标题
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),

        // 图片上传区域
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: width ?? double.infinity,
            height: height ?? 200.w,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.grey[50],
              borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
              border: showBorder
                  ? Border.all(
                      color: borderColor ??
                          (hasImage ? Colors.transparent : Colors.grey[200]!),
                      width: 1.5,
                    )
                  : null,
              boxShadow: hasImage
                  ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: hasImage
                ? _buildImage(context)
                : _buildUploadPlaceholder(context, primaryColor),
          ),
        ),
      ],
    );
  }

  /// 构建已上传的图片
  Widget _buildImage(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          child: Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: errorIcon ??
                    Icon(
                      Icons.broken_image,
                      size: 48.sp,
                      color: Colors.grey[400],
                    ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  color: Theme.of(context).primaryColor,
                ),
              );
            },
          ),
        ),
        // 重新上传标签
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            margin: EdgeInsets.all(6.w),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              '重新上传',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建上传占位符
  Widget _buildUploadPlaceholder(BuildContext context, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          uploadIcon ??
              Icon(
                Icons.add_a_photo_outlined,
                size: 24.sp,
                color: Colors.grey[600],
              ),
          SizedBox(height: 6.h),
          Text(
            uploadText ?? '点击上传',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 规范化图片地址
  /// [url] 原始图片地址
  String _normalizeImageUrl(String? url) {
    final value = (url ?? '').trim();
    if (value.isEmpty) return '';
    if (value.toLowerCase() == 'null' || value.toLowerCase() == 'undefined') {
      return '';
    }
    return value;
  }
}
