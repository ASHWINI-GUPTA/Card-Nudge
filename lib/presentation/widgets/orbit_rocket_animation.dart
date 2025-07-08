import 'dart:math';
import 'package:flutter/material.dart';

class OrbitRocketAnimation extends StatefulWidget {
  const OrbitRocketAnimation({super.key});

  @override
  State<OrbitRocketAnimation> createState() => _OrbitRocketAnimationState();
}

class _OrbitRocketAnimationState extends State<OrbitRocketAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _earthSize = 64.0;
  final _moonSize = 24.0;
  final _rocketSize = 24.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: 350,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(350, 250),
            painter: OrbitPathPainter(
              earthSize: _earthSize,
              moonSize: _moonSize,
            ),
          ),
          // Earth
          Positioned(
            left: 20,
            bottom: 100,
            child: Text('🌏', style: TextStyle(fontSize: _earthSize)),
          ),
          // Moon
          Positioned(
            right: 20,
            top: 100,
            child: Text('🌖', style: TextStyle(fontSize: _moonSize)),
          ),
          // Animated Rocket
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final pathPosition = _calculatePathPosition(_animation.value);
              return Positioned(
                left: pathPosition.dx,
                top: pathPosition.dy,
                child: Transform.rotate(
                  angle: _calculateRotation(pathPosition, _animation.value),
                  child: Text('🚀', style: TextStyle(fontSize: _rocketSize)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Offset _calculatePathPosition(double t) {
    final width = 350.0;
    final height = 250.0;

    // Adjust starting and ending points to match Earth and Moon positions
    final startX = 20.0 + _earthSize * 0.75; // Start from Earth's right side
    final startY = height - 100.0 - _earthSize * 0.25; // Start from Earth's top
    final endX = width - 20.0 - _moonSize * 0.5; // End at Moon's center
    final endY = 100.0 + _moonSize * 0.5; // Moon's vertical position

    // Control point for the curve - higher and more to the right for better arc
    final controlX =
        width * 0.6; // Move control point right for asymmetric curve
    final controlY = height * 0.15; // Higher control point for better arc

    // Quadratic bezier curve calculation
    final x =
        (1 - t) * (1 - t) * startX + 2 * (1 - t) * t * controlX + t * t * endX;
    final y =
        (1 - t) * (1 - t) * startY + 2 * (1 - t) * t * controlY + t * t * endY;

    return Offset(x - _rocketSize / 2, y - _rocketSize / 2);
  }

  double _calculateRotation(Offset position, double t) {
    final width = 350.0;
    final height = 250.0;

    // Calculate the control points
    final startX = 20.0 + _earthSize * 0.75;
    final startY = height - 100.0 - _earthSize * 0.25;
    final endX = width - 20.0 - _moonSize * 0.5;
    final endY = 100.0 + _moonSize * 0.5;
    final controlX = width * 0.6;
    final controlY = height * 0.15;

    // Calculate the tangent vector at the current point
    final dx = 2 * (1 - t) * (controlX - startX) + 2 * t * (endX - controlX);
    final dy = 2 * (1 - t) * (controlY - startY) + 2 * t * (endY - controlY);

    // Calculate the angle and adjust for rocket orientation
    double angle = atan2(dy, dx);

    // Adjust the rotation for different phases of the journey
    if (t < 0.1) {
      // Initial phase: blend between vertical and path angle
      angle = -pi / 2 + (t / 0.1) * (angle + pi / 2);
    } else if (t > 0.9) {
      // Final phase: adjust for moon approach
      angle = angle * (1 - ((t - 0.9) / 0.1));
    }

    return angle - pi / 2; // Adjust to make rocket point along the path
  }
}

class OrbitPathPainter extends CustomPainter {
  final double earthSize;
  final double moonSize;

  OrbitPathPainter({required this.earthSize, required this.moonSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final path = Path();

    // Start from Earth's right side
    final startX = 20.0 + earthSize * 0.75;
    final startY = size.height - 100.0 - earthSize * 0.25;

    // End at Moon
    final endX = size.width - 20.0 - moonSize * 0.5;
    final endY = 100.0 + moonSize * 0.5;

    path.moveTo(startX, startY);

    // Control point for better arc
    path.quadraticBezierTo(
      size.width * 0.6, // Control point X
      size.height * 0.15, // Control point Y
      endX,
      endY,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant OrbitPathPainter oldDelegate) =>
      oldDelegate.earthSize != earthSize || oldDelegate.moonSize != moonSize;
}
