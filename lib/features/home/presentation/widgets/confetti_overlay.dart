import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class ConfettiOverlay extends StatefulWidget {
  final bool isActive;
  final Duration duration;
  final int particleCount;

  const ConfettiOverlay({
    super.key,
    required this.isActive,
    this.duration = const Duration(seconds: 3),
    this.particleCount = 100,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _initializeParticles();
    
    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _initializeParticles();
        _controller.reset();
        _controller.forward();
      } else {
        _controller.stop();
      }
    }
  }

  void _initializeParticles() {
    final random = math.Random();
    _particles = List.generate(widget.particleCount, (index) {
      return ConfettiParticle(
        x: random.nextDouble(),
        y: -0.1,
        velocityX: (random.nextDouble() - 0.5) * 2,
        velocityY: random.nextDouble() * 2 + 1,
        rotation: random.nextDouble() * math.pi * 2,
        rotationSpeed: (random.nextDouble() - 0.5) * 4,
        color: _confettiColors[random.nextInt(_confettiColors.length)],
        shape: random.nextBool() ? ParticleShape.rectangle : ParticleShape.circle,
        size: random.nextDouble() * 8 + 4,
      );
    });
  }

  static const List<Color> _confettiColors = [
    Color(0xFF6C63FF), // Primary
    Color(0xFFFF6584), // Secondary
    Color(0xFF4ECDC4), // Teal
    Color(0xFFFFE066), // Yellow
    Color(0xFF95E1D3), // Mint
    Color(0xFFFF8A65), // Orange
    Color(0xFF81C784), // Green
    Color(0xFF64B5F6), // Blue
    Color(0xFFBA68C8), // Purple
    Color(0xFFF06292), // Pink
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: ConfettiPainter(
              particles: _particles,
              progress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

enum ParticleShape { rectangle, circle }

class ConfettiParticle {
  final double x;
  final double y;
  final double velocityX;
  final double velocityY;
  final double rotation;
  final double rotationSpeed;
  final Color color;
  final ParticleShape shape;
  final double size;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.shape,
    required this.size,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;
  static const double gravity = 2.0;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    for (final particle in particles) {
      // Calculate current position with physics
      final time = progress;
      final currentX = particle.x + particle.velocityX * time;
      final currentY = particle.y + particle.velocityY * time + 0.5 * gravity * time * time;
      final currentRotation = particle.rotation + particle.rotationSpeed * time;

      // Skip particles that are off-screen
      if (currentX < -0.1 || currentX > 1.1 || currentY > 1.1) continue;

      final paint = Paint()
        ..color = particle.color.withOpacity(math.max(0.0, 1.0 - progress * 0.3))
        ..style = PaintingStyle.fill;

      final actualX = currentX * size.width;
      final actualY = currentY * size.height;

      canvas.save();
      canvas.translate(actualX, actualY);
      canvas.rotate(currentRotation);

      switch (particle.shape) {
        case ParticleShape.rectangle:
          final rect = Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 0.6,
          );
          canvas.drawRect(rect, paint);
          break;
        case ParticleShape.circle:
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}