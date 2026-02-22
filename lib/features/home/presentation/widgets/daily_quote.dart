import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import 'dart:async';

class DailyQuote extends StatefulWidget {
  final String quote;
  final Duration typingSpeed;
  final bool autoStart;

  const DailyQuote({
    super.key,
    required this.quote,
    this.typingSpeed = const Duration(milliseconds: 30),
    this.autoStart = true,
  });

  @override
  State<DailyQuote> createState() => _DailyQuoteState();
}

class _DailyQuoteState extends State<DailyQuote>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  Timer? _typingTimer;
  String _displayedText = '';
  int _currentIndex = 0;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    if (widget.autoStart) {
      _startTyping();
    }
  }

  @override
  void didUpdateWidget(DailyQuote oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quote != widget.quote) {
      _resetTyping();
      if (widget.autoStart) {
        _startTyping();
      }
    }
  }

  void _startTyping() {
    _fadeController.forward();
    
    setState(() {
      _isTyping = true;
      _currentIndex = 0;
      _displayedText = '';
    });

    _typingTimer = Timer.periodic(widget.typingSpeed, (timer) {
      if (_currentIndex < widget.quote.length) {
        setState(() {
          _displayedText += widget.quote[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
        setState(() {
          _isTyping = false;
        });
      }
    });
  }

  void _resetTyping() {
    _typingTimer?.cancel();
    _fadeController.reset();
    setState(() {
      _displayedText = '';
      _currentIndex = 0;
      _isTyping = false;
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.glassBorder.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quote icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.format_quote,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 16),
            
            // Typewriter text
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _calculateTextHeight(),
              child: Stack(
                children: [
                  // Main text
                  Text(
                    '"$_displayedText"',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // Cursor
                  if (_isTyping)
                    Positioned(
                      right: _getCursorPosition(),
                      bottom: 0,
                      child: AnimatedOpacity(
                        opacity: _isTyping ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: BlinkingCursor(),
                      ),
                    ),
                ],
              ),
            ),
            
            // Completion indicator
            if (!_isTyping && _displayedText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _calculateTextHeight() {
    if (_displayedText.isEmpty) return 24;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: '"$_displayedText"',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
      maxLines: null,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 72);
    return textPainter.height + 4;
  }

  double _getCursorPosition() {
    if (_displayedText.isEmpty) return 0;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: '"$_displayedText"',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    return (MediaQuery.of(context).size.width - 72 - textPainter.width) / 2;
  }
}

class BlinkingCursor extends StatefulWidget {
  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 1.5,
        height: 20,
        color: AppColors.primary,
      ),
    );
  }
}