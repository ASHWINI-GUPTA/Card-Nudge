import 'package:flutter/material.dart';

class CreditCardColorDotIndicator extends StatefulWidget {
  final bool animate;

  const CreditCardColorDotIndicator({super.key, this.animate = true});

  @override
  State<CreditCardColorDotIndicator> createState() =>
      _CreditCardColorDotIndicatorState();
}

class _CreditCardColorDotIndicatorState
    extends State<CreditCardColorDotIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late List<Animation<double>> _animations;

  final List<Color> _dotColors = [
    const Color.fromRGBO(21, 101, 192, 1),
    const Color.fromRGBO(239, 108, 0, 1),
    const Color.fromRGBO(211, 47, 47, 1),
    const Color.fromRGBO(56, 142, 60, 1),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      )..repeat();

      _animations = List.generate(
        4,
        (index) => Tween<double>(begin: 0.4, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller!,
            curve: Interval(
              index * 0.15,
              (index * 0.15) + 0.4,
              curve: Curves.easeInOut,
            ),
          ),
        ),
      );
    } else {
      _animations = List.generate(4, (index) => AlwaysStoppedAnimation(1.0));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:
          widget.animate && _controller != null
              ? _controller!
              : Listenable.merge([]),
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Transform.scale(
                scale: _animations[index].value,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _dotColors[index % _dotColors.length].withAlpha(
                      (_animations[index].value * 255).toInt(),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
