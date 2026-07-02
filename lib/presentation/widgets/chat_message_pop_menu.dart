import 'package:flutter/material.dart';

class ChatMessageMenuAction {
  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  const ChatMessageMenuAction({
    required this.iconAsset,
    required this.label,
    required this.onTap,
  });
}

class ChatMessagePopMenu extends StatefulWidget {
  final Widget child;
  final List<ChatMessageMenuAction> actions;

  const ChatMessagePopMenu({
    super.key,
    required this.child,
    required this.actions,
  });

  @override
  State<ChatMessagePopMenu> createState() => _ChatMessagePopMenuState();
}

class _ChatMessagePopMenuState extends State<ChatMessagePopMenu> {
  static const _verticalMargin = 10.0;
  static const _horizontalMargin = 10.0;

  OverlayEntry? _overlayEntry;
  RenderBox? _childBox;
  RenderBox? _overlayBox;
  TapDownDetails? _tapDownDetails;
  ModalRoute<dynamic>? _route;
  bool _willPopRegistered = false;

  @override
  void dispose() {
    _hideMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) => _tapDownDetails = details,
      onLongPress: _showMenu,
      child: widget.child,
    );
  }

  void _showMenu() {
    if (widget.actions.isEmpty) return;
    _hideMenu();

    _childBox = context.findRenderObject() as RenderBox?;
    _overlayBox = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (_childBox == null || _overlayBox == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            final offset = event.localPosition;
            if (_menuRect.contains(
              Offset(offset.dx - _horizontalMargin, offset.dy),
            )) {
              return;
            }
            _hideMenu();
          },
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: _overlayBox!.size.width - 2 * _horizontalMargin,
                minWidth: 0,
              ),
              child: CustomMultiChildLayout(
                delegate: _MenuLayoutDelegate(
                  anchorSize: _childBox!.size,
                  anchorOffset: _childBox!.localToGlobal(
                    const Offset(-_horizontalMargin, 0),
                  ),
                  verticalMargin: _verticalMargin,
                  keyboardHeight: keyboardHeight,
                  onTapDownOffset: _tapDownDetails?.globalPosition,
                ),
                children: [
                  LayoutId(
                    id: _MenuLayoutId.content,
                    child: _MenuContent(
                      actions: widget.actions,
                      onActionTap: _hideMenu,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    _registerWillPopCallback();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _removeWillPopCallback();
  }

  void _registerWillPopCallback() {
    if (_willPopRegistered) return;
    _route = ModalRoute.of(context);
    _route?.addScopedWillPopCallback(_handleWillPop);
    _willPopRegistered = _route != null;
  }

  void _removeWillPopCallback() {
    if (!_willPopRegistered) return;
    _route?.removeScopedWillPopCallback(_handleWillPop);
    _route = null;
    _willPopRegistered = false;
  }

  Future<bool> _handleWillPop() async {
    if (_overlayEntry == null) return true;
    _hideMenu();
    return false;
  }
}

Rect _menuRect = Rect.zero;

class _MenuContent extends StatelessWidget {
  final List<ChatMessageMenuAction> actions;
  final VoidCallback onActionTap;

  const _MenuContent({
    required this.actions,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(minWidth: 117),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8E9AB0).withValues(alpha: 0.16),
              offset: const Offset(0, 6),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < actions.length; i++)
              _MenuItem(
                action: actions[i],
                showLine: i != actions.length - 1,
                onActionTap: onActionTap,
              ),
          ],
        ),
      ),
    );
  }
}

enum _MenuLayoutId {
  content,
}

enum _MenuPosition {
  bottomLeft,
  bottomCenter,
  bottomRight,
  topLeft,
  topCenter,
  topRight,
}

class _MenuLayoutDelegate extends MultiChildLayoutDelegate {
  final Size anchorSize;
  final Offset anchorOffset;
  final double verticalMargin;
  final double keyboardHeight;
  final Offset? onTapDownOffset;

  _MenuLayoutDelegate({
    required this.anchorSize,
    required this.anchorOffset,
    required this.verticalMargin,
    required this.keyboardHeight,
    this.onTapDownOffset,
  });

  @override
  void performLayout(Size size) {
    var contentSize = Size.zero;
    var contentOffset = Offset.zero;

    var anchorCenterX = anchorOffset.dx + anchorSize.width / 2;
    var anchorTopY = anchorOffset.dy;
    var anchorBottomY = anchorTopY + anchorSize.height;
    final touchY = onTapDownOffset?.dy;

    if (hasChild(_MenuLayoutId.content)) {
      contentSize = layoutChild(
        _MenuLayoutId.content,
        BoxConstraints.loose(size),
      );
    }

    final visibleHeight = size.height - keyboardHeight;
    var isTop = anchorBottomY > visibleHeight / 2;
    final minTopMargin = contentSize.height;
    if (touchY != null && anchorTopY < minTopMargin) {
      if (touchY < minTopMargin) {
        isTop = false;
        if (anchorSize.height > size.height * 0.8) {
          anchorBottomY = touchY;
        }
      } else {
        anchorTopY = touchY;
      }
    }

    final menuPosition = _resolveMenuPosition(
      isTop: isTop,
      anchorCenterX: anchorCenterX,
      contentWidth: contentSize.width,
      screenWidth: size.width,
    );

    switch (menuPosition) {
      case _MenuPosition.bottomCenter:
        contentOffset = Offset(
          anchorCenterX - contentSize.width / 2,
          anchorBottomY + verticalMargin,
        );
        break;
      case _MenuPosition.bottomLeft:
        contentOffset = Offset(0, anchorBottomY + verticalMargin);
        break;
      case _MenuPosition.bottomRight:
        contentOffset = Offset(
          size.width - contentSize.width,
          anchorBottomY + verticalMargin,
        );
        break;
      case _MenuPosition.topCenter:
        contentOffset = Offset(
          anchorCenterX - contentSize.width / 2,
          anchorTopY - verticalMargin - contentSize.height,
        );
        break;
      case _MenuPosition.topLeft:
        contentOffset = Offset(
          0,
          anchorTopY - verticalMargin - contentSize.height,
        );
        break;
      case _MenuPosition.topRight:
        contentOffset = Offset(
          size.width - contentSize.width,
          anchorTopY - verticalMargin - contentSize.height,
        );
        break;
    }

    if (hasChild(_MenuLayoutId.content)) {
      final maxTop = visibleHeight - contentSize.height;
      if (contentOffset.dy > maxTop) {
        contentOffset = Offset(contentOffset.dx, maxTop);
      }
      if (contentOffset.dy < 0) {
        contentOffset = Offset(contentOffset.dx, 0);
      }
      positionChild(_MenuLayoutId.content, contentOffset);
    }

    _menuRect = Rect.fromLTWH(
      contentOffset.dx,
      contentOffset.dy,
      contentSize.width,
      contentSize.height,
    );
  }

  _MenuPosition _resolveMenuPosition({
    required bool isTop,
    required double anchorCenterX,
    required double contentWidth,
    required double screenWidth,
  }) {
    if (anchorCenterX - contentWidth / 2 < 0) {
      return isTop ? _MenuPosition.topLeft : _MenuPosition.bottomLeft;
    }
    if (anchorCenterX + contentWidth / 2 > screenWidth) {
      return isTop ? _MenuPosition.topRight : _MenuPosition.bottomRight;
    }
    return isTop ? _MenuPosition.topCenter : _MenuPosition.bottomCenter;
  }

  @override
  bool shouldRelayout(covariant _MenuLayoutDelegate oldDelegate) {
    return anchorSize != oldDelegate.anchorSize ||
        anchorOffset != oldDelegate.anchorOffset ||
        verticalMargin != oldDelegate.verticalMargin ||
        keyboardHeight != oldDelegate.keyboardHeight ||
        onTapDownOffset != oldDelegate.onTapDownOffset;
  }
}

class _MenuItem extends StatelessWidget {
  final ChatMessageMenuAction action;
  final bool showLine;
  final VoidCallback onActionTap;

  const _MenuItem({
    required this.action,
    required this.showLine,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        onActionTap();
        action.onTap();
      },
      child: Container(
        height: 48,
        constraints: const BoxConstraints(minWidth: 117),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: showLine
            ? const BoxDecoration(
                border: BorderDirectional(
                  bottom: BorderSide(
                    color: Color(0xFFE8EAEF),
                    width: 1,
                  ),
                ),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              action.iconAsset,
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 12),
            Text(
              action.label,
              style: const TextStyle(
                color: Color(0xFF0C1C33),
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
