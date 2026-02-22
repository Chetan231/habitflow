import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedCheckmark extends StatefulWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  final Duration duration;

  const AnimatedCheckmark({
    super.key,
    this.size = 24.0,
    this.color = Colors.green,
    this.strokeWidth = 2.5,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _CheckmarkPainter(
            progress: _animation.value,
            color: widget.color,
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CheckmarkPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    
    // Define checkmark points
    final startPoint = Offset(size.width * 0.2, size.height * 0.5);
    final midPoint = Offset(size.width * 0.45, size.height * 0.7);
    final endPoint = Offset(size.width * 0.8, size.height * 0.3);

    // Calculate total path length for animation
    final firstSegmentLength = (midPoint - startPoint).distance;
    final secondSegmentLength = (endPoint - midPoint).distance;
    final totalLength = firstSegmentLength + secondSegmentLength;
    
    final firstSegmentProgress = firstSegmentLength / totalLength;
    
    path.moveTo(startPoint.dx, startPoint.dy);
    
    if (progress <= firstSegmentProgress) {
      // Draw first segment (start to mid)
      final segmentProgress = progress / firstSegmentProgress;
      final currentPoint = Offset.lerp(startPoint, midPoint, segmentProgress)!;
      path.lineTo(currentPoint.dx, currentPoint.dy);
    } else {
      // Draw complete first segment
      path.lineTo(midPoint.dx, midPoint.dy);
      
      // Draw second segment (mid to end)
      final secondProgress = (progress - firstSegmentProgress) / (1 - firstSegmentProgress);
      final currentPoint = Offset.lerp(midPoint, endPoint, secondProgress)!;
      path.lineTo(currentPoint.dx, currentPoint.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}