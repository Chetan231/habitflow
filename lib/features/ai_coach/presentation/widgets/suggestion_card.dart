import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';

class SuggestionCard extends StatefulWidget {
  final String title;
  final String description;
  final String icon;
  final bool isExpanded;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onDismiss;

  const SuggestionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.isExpanded = false,
    this.onTap,
    this.onAccept,
    this.onDismiss,
  });

  @override
  State<SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<SuggestionCard>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _expandController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _expandAnimation;
  
  bool _isExpanded = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
    
    _isExpanded = widget.isExpanded;
    if (_isExpanded) {
      _expandController.value = 1.0;
    }
    
    // Start shimmer animation on hover or periodically
    _startShimmerLoop();
  }

  void _startShimmerLoop() {
    Future.delayed(Duration(milliseconds: (2000 + (widget.hashCode % 3000)).toInt()), () {
      if (mounted) {
        _shimmerController.forward().then((_) {
          _shimmerController.reset();
          _startShimmerLoop();
        });
      }
    });
  }

  @override
  void didUpdateWidget(SuggestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded) {
      setState(() {
        _isExpanded = widget.isExpanded;
      });
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
    
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _shimmerController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
      },
      child: GestureDetector(
        onTap: _toggleExpanded,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppColors.cardBackground,
                AppColors.cardBackground.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              width: 1.5,
              color: Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow.withOpacity(_isHovered ? 0.3 : 0.1),
                blurRadius: _isHovered ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated shimmer highlight
              AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.primary.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
                        end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
                      ),
                    ),
                  );
                },
              ),
              
              // Gradient border overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(_isHovered ? 0.3 : 0.1),
                      AppColors.secondary.withOpacity(_isHovered ? 0.3 : 0.1),
                      AppColors.primary.withOpacity(_isHovered ? 0.3 : 0.1),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.5),
                    color: AppColors.cardBackground,
                  ),
                  child: _buildCardContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    widget.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Title
              Expanded(
                child: Text(
                  widget.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Expand icon
              AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ),
            ],
          ),
          
          // Expandable content
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // Description
                Text(
                  widget.description,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Action buttons
                Row(
                  children: [
                    // Accept button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onAccept,
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(
                          'Add to Habits',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Dismiss button
                    OutlinedButton.icon(
                      onPressed: widget.onDismiss,
                      icon: const Icon(Icons.close, size: 18),
                      label: Text(
                        'Dismiss',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(
                          color: AppColors.glassBorder,
                          width: 1,
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}