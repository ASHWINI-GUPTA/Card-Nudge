import 'package:card_nudge/presentation/widgets/emoji_blast.dart';
import 'package:flutter/material.dart';

import '../../helper/emoji_helper.dart';

class OfflineButton extends StatefulWidget {
  @override
  State<OfflineButton> createState() => _OfflineButtonState();
}

class _OfflineButtonState extends State<OfflineButton>
    with SingleTickerProviderStateMixin {
  int _pressCount = 0;
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  Key? _blastKey;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 16.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePressed() {
    setState(() {
      _pressCount++;
      if (_pressCount >= 3) {
        _blastKey = UniqueKey();
        _pressCount = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isGlowing = _pressCount >= 3;
    final mediaQuery = MediaQuery.of(context);
    final double topPadding = mediaQuery.padding.top + 24;
    final double rightPadding = 24;

    return Positioned(
      top: topPadding,
      right: rightPadding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                decoration:
                    isGlowing
                        ? BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 238, 116, 110),
                              blurRadius: _glowAnimation.value + 12,
                              spreadRadius: _glowAnimation.value,
                            ),
                          ],
                        )
                        : null,
                child: IconButton(
                  style: ElevatedButton.styleFrom(
                    enableFeedback: true,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF23272F)
                            : const Color(0xFFF5F6FA),
                    foregroundColor: Colors.blue,
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: _handlePressed,
                  icon: const Icon(Icons.wifi_off, color: Colors.blue),
                ),
              );
            },
          ),
          if (_blastKey != null)
            Positioned(
              child: EmojiBlast(
                key: _blastKey,
                count: 24,
                emojis: List.from(blastEmojiList),
                duration: const Duration(milliseconds: 1200),
                minDistance: 100,
                maxDistance: 500,
                onBlastEnd: () {
                  setState(() {
                    _blastKey = null;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
