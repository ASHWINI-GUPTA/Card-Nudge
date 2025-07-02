import 'dart:math';

import 'package:flutter/material.dart';

class EmojiBlast extends StatefulWidget {
  final int count;
  final List<String> emojis;
  final Duration duration;
  final double minDistance;
  final double maxDistance;
  final VoidCallback? onBlastEnd;
  final Key? triggerKey;

  const EmojiBlast({
    Key? key,
    required this.count,
    required this.emojis,
    this.duration = const Duration(milliseconds: 1200),
    this.minDistance = 100,
    this.maxDistance = 500,
    this.onBlastEnd,
    this.triggerKey,
  }) : super(key: key);

  @override
  State<EmojiBlast> createState() => _EmojiBlastState();
}

class _EmojiBlastState extends State<EmojiBlast> with TickerProviderStateMixin {
  late List<_BlastParticle> _blasts;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _startBlast();
  }

  @override
  void didUpdateWidget(covariant EmojiBlast oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.triggerKey != oldWidget.triggerKey) {
      _startBlast();
    }
  }

  void _startBlast() {
    setState(() {
      _visible = true;
      _blasts = List.generate(
        widget.count,
        (i) => _BlastParticle(
          emoji: (widget.emojis..shuffle()).first,
          angle: (i * (2 * pi / widget.count)),
          duration: widget.duration,
          minDistance: widget.minDistance,
          maxDistance: widget.maxDistance,
        ),
      );
    });
    Future.delayed(widget.duration, () {
      if (mounted) {
        setState(() => _visible = false);
        widget.onBlastEnd?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return SizedBox(
      child: Stack(alignment: Alignment.center, children: _blasts),
    );
  }
}

// --- Individual blast particle ---
class _BlastParticle extends StatefulWidget {
  final String emoji;
  final double angle;
  final Duration duration;
  final double minDistance;
  final double maxDistance;

  const _BlastParticle({
    required this.emoji,
    required this.angle,
    required this.duration,
    required this.minDistance,
    required this.maxDistance,
  });

  @override
  State<_BlastParticle> createState() => _BlastParticleState();
}

class _BlastParticleState extends State<_BlastParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dx;
  late Animation<double> _dy;
  late Animation<double> _opacity;
  late double distance;

  @override
  void initState() {
    super.initState();
    distance =
        widget.minDistance +
        Random().nextDouble() * (widget.maxDistance - widget.minDistance);
    _controller = AnimationController(
      duration: widget.duration * 5 ~/ 3, // slightly longer for fade
      vsync: this,
    )..forward();

    _dx = Tween<double>(
      begin: 0,
      end: distance * cos(widget.angle),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _dy = Tween<double>(
      begin: 0,
      end: -distance * sin(widget.angle),
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
