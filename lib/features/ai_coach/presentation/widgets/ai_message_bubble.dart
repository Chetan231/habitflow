import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import 'dart:async';

class AiMessageBubble extends StatefulWidget {
  final String message;
  final bool showAvatar;
  final Duration typingSpeed;
  final bool autoStart;
  final VoidCallback? onTypingComplete;

  const AiMessageBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
    this.typingSpeed = const Duration(milliseconds: 30),
    this.autoStart = true,
    this.onTypingComplete,
  });

  @override
  State<AiMessageBubble> createState() => _AiMessageBubbleState();
}

class _AiMessageBubbleState extends State<AiMessageBubble>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  Timer? _typingTimer;
  String _displayedText = '';
  int _currentIndex = 0;
  bool _isTyping = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Start entrance animation
    _fadeController.forward();
    _slideController.forward();
    
    if (widget.autoStart) {
      // Start typing after entrance animation
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _startTyping();
        }
      });
    }
  }

  @override
  void didUpdateWidget(AiMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) {
      _resetTyping();
      if (widget.autoStart) {
        _startTyping();
      }
    }
  }

  void _startTyping() {
    setState(() {
      _isTyping = true;
      _isComplete = false;
      _currentIndex = 0;
      _displayedText = '';
    });

    _typingTimer = Timer.periodic(widget.typingSpeed, (timer) {
      if (_currentIndex < widget.message.length) {
        setState(() {
          _displayedText += widget.message[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
        setState(() {
          _isTyping = false;
          _isComplete = true;
        });
        widget.onTypingComplete?.call();
      }
    });
  }

  void _resetTyping() {
    _typingTimer?.cancel();
    setState(() {
      _displayedText = '';
      _currentIndex = 0;
      _isTyping = false;
      _isComplete = false;
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Avatar
              if (widget.showAvatar) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '🤖',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              
              // Message bubble
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border(
                      left: BorderSide(
                        color: AppColors.primary,
                        width: 4,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cardShadow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI Coach label
                      Row(
                        children: [
                          Text(
                            'AI Coach',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_isTyping)
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.primary.withOpacity(0.6),
                                ),
                              ),
                            )
                          else if (_isComplete)
                            Icon(
                              Icons.check_circle,
                              size: 12,
                              color: AppColors.success,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Typing text with cursor
                      Stack(
                        children: [
                          Text(
                            _displayedText,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          
                          // Blinking cursor
                          if (_isTyping)
                            Positioned(
                              left: _getCursorPosition(),
                              top: 0,
                              child: BlinkingCursor(),
                            ),
                        ],
                      ),
                      
                      // Thinking dots when starting
                      if (_displayedText.isEmpty && _isTyping) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Thinking',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ThinkingDots(),
                          ],
                        ),
                      ],
                      
                      // Action buttons (if message is complete)
                      if (_isComplete && widget.message.contains('?')) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildActionButton(
                              '👍',
                              'Helpful',
                              () => _onFeedback('helpful'),
                            ),
                            const SizedBox(width: 8),
                            _buildActionButton(
                              '👎',
                              'Not helpful',
                              () => _onFeedback('not_helpful'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String emoji, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.glassBorder.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onFeedback(String feedback) {
    // Handle feedback - could send to analytics or AI service
    print('AI Coach feedback: $feedback');
  }

  double _getCursorPosition() {
    if (_displayedText.isEmpty) return 0;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: _displayedText,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          height: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    return textPainter.width;
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
        width: 2,
        height: 20,
        color: AppColors.primary,
      ),
    );
  }
}

class ThinkingDots extends StatefulWidget {
  @override
  State<ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<ThinkingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _animations = List.generate(3, (index) {
      return Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2,
            (index * 0.2) + 0.4,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
    
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Opacity(
              opacity: _animations[index].value,
              child: Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}