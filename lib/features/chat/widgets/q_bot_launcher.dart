import 'package:flutter/material.dart';

import '../views/q_bot_screen.dart';
import '../../../core/l10n/app_language.dart';

class QBotLauncher extends StatefulWidget {
  const QBotLauncher({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<QBotLauncher> createState() => _QBotLauncherState();
}

class _QBotLauncherState extends State<QBotLauncher> {
  static const _bubbleSize = 58.0;
  final ValueNotifier<Offset?> _position = ValueNotifier(null);
  bool _isDragging = false;
  bool _isHidden = false;

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  Future<void> _openQBot() async {
    final context = widget.navigatorKey.currentContext;
    if (context == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: const Color(0xFFFFFBF2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.94,
        child: QBotScreen(closeAsPanel: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxX = (constraints.maxWidth - _bubbleSize - 8).clamp(
          8.0,
          double.infinity,
        );
        final maxY = (constraints.maxHeight - _bubbleSize - 16).clamp(
          8.0,
          double.infinity,
        );

        Offset constrained(Offset value) =>
            Offset(value.dx.clamp(8.0, maxX), value.dy.clamp(8.0, maxY));

        return Stack(
          children: [
            RepaintBoundary(child: widget.child),
            if (_isDragging)
              Positioned(
                left: constraints.maxWidth / 2 - 32,
                bottom: 22,
                child: IgnorePointer(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD32F2F),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 14,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 34,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (!_isHidden)
              ValueListenableBuilder<Offset?>(
                valueListenable: _position,
                builder: (context, storedPosition, child) {
                  final position = constrained(
                    storedPosition ??
                        Offset(maxX, (maxY - 80).clamp(8.0, maxY)),
                  );
                  return Positioned(
                    left: position.dx,
                    top: position.dy,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _openQBot,
                      onPanStart: (_) => setState(() => _isDragging = true),
                      onPanUpdate: (details) {
                        _position.value = constrained(
                          (_position.value ?? position) + details.delta,
                        );
                      },
                      onPanEnd: (_) {
                        final latest = constrained(_position.value ?? position);
                        final bubbleCenter =
                            latest +
                            const Offset(_bubbleSize / 2, _bubbleSize / 2);
                        final removeCenter = Offset(
                          constraints.maxWidth / 2,
                          constraints.maxHeight - 54,
                        );
                        if ((bubbleCenter - removeCenter).distance < 86) {
                          setState(() {
                            _isDragging = false;
                            _isHidden = true;
                          });
                          return;
                        }
                        _position.value = Offset(
                          latest.dx + _bubbleSize / 2 < constraints.maxWidth / 2
                              ? 8
                              : maxX,
                          latest.dy,
                        );
                        setState(() => _isDragging = false);
                      },
                      onPanCancel: () => setState(() => _isDragging = false),
                      child: child,
                    ),
                  );
                },
                child: Semantics(
                  button: true,
                  label: tr('Open Q Bot AI shopping assistant'),
                  child: const Material(
                    elevation: 10,
                    color: Color(0xFFEE7424),
                    shape: CircleBorder(),
                    child: SizedBox(
                      width: _bubbleSize,
                      height: _bubbleSize,
                      child: Icon(
                        Icons.smart_toy_rounded,
                        color: Colors.white,
                        size: 29,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
