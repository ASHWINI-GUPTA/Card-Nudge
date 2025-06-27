import 'package:flutter/material.dart';
import 'dart:math';

class OfflineButton extends StatefulWidget {
  @override
  State<OfflineButton> createState() => _OfflineButtonState();
}

class _OfflineButtonState extends State<OfflineButton>
    with SingleTickerProviderStateMixin {
  int _pressCount = 0;
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  // AG TODO: Create a Helper class for emojis
  final List<String> _emojis = [
    '😂',
    '🤪',
    '😜',
    '🥳',
    '🤡',
    '👾',
    '🦄',
    '💥',
    '🎉',
    '😎',
    '🚀',
    '✨',
    '🔥',
    '🍕',
    '🍔',
    '🎈',
    '😺',
    '😹',
    '🙃',
    '😇',
    '🎮',
    '🎵',
    '🎤',
    '📸',
    '🍩',
    '🍭',
    '🍦',
    '🍉',
    '🌈',
    '🧃',
    '🤖',
    '👑',
    '💫',
    '🎊',
    '🧁',
    '🥤',
    '🛸',
    '🌟',
    '💯',
    '🤩',
    '😍',
    '👍',
    '👎',
    '👏',
    '🙌',
    '🙏',
    '🤞',
    '👌',
    '🤘',
    '🤙',
    '💪',
    '🥳',
    '🤯',
    '😴',
    '🤤',
    '🤑',
    '🤫',
    '🤬',
    '🤭',
    '🤫',
    '🤥',
    '🤧',
    '🤒',
    '🤕',
    '🤮',
    '🤢',
    '🤤',
    '🥴',
    '😵',
    '🤯',
    '🤠',
    '😎',
    '🤓',
    '🧐',
    '🥳',
    '🙂',
    '🤗',
    '🙃',
    '😇',
    '😈',
    '👿',
    '👹',
    '👺',
    '🤡',
    '👻',
    '👽',
    '👾',
    '🤖',
    '💩',
    '😺',
    '😸',
    '😹',
    '😻',
    '😼',
    '😽',
    '🙀',
    '😿',
    '😾',
  ];
  bool _showBlast = false;
  List<_EmojiBlast> _blasts = [];

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
        _showBlast = true;
        _blasts = List.generate(
          24, // Number of emojis to blast
          (i) => _EmojiBlast(
            emoji: (_emojis..shuffle()).first,
            key: UniqueKey(),
            // Calculate angle for full 360-degree distribution
            angle: (i * (2 * pi / 24)),
          ),
        );
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            setState(() {
              _showBlast = false;
              _pressCount = 0;
            });
          }
        });
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
          // Position the blasts relative to the button
          if (_showBlast)
            Positioned(
              child: SizedBox(
                child: Stack(alignment: Alignment.center, children: _blasts),
              ),
            ),
        ],
      ),
    );
  }
}

// Helper widget for emoji blast animation
class _EmojiBlast extends StatefulWidget {
  final String emoji;
  final double angle;
  const _EmojiBlast({Key? key, required this.emoji, required this.angle})
    : super(key: key);

  @override
  State<_EmojiBlast> createState() => _EmojiBlastState();
}

class _EmojiBlastState extends State<_EmojiBlast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dx;
  late Animation<double> _dy;
  late Animation<double> _opacity;
  late double distance;

  @override
  void initState() {
    super.initState();
    // Randomize distance for varied spread
    distance = 100 + (Random().nextInt(5) * 100); // 100 to 500 pixels
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..forward();

    _dx = Tween<double>(
      begin: 0,
      end: distance * cos(widget.angle),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _dy = Tween<double>(
      begin: 0,
      end:
          -distance *
          sin(widget.angle), // Negative for upwards movement in Flutter
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacity = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_dx.value, _dy.value),
          child: Opacity(
            opacity: _opacity.value,
            child: Text(widget.emoji, style: const TextStyle(fontSize: 28)),
          ),
        );
      },
    );
  }
}
