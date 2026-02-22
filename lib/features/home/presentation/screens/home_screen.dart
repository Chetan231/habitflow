import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import 'today_screen.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../../../ai_coach/presentation/screens/ai_coach_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final Widget child;
  
  const HomeScreen({
    super.key,
    required this.child,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> 
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late List<AnimationController> _tabAnimations;

  final List<_TabItem> _tabs = [
    _TabItem(
      index: 0,
      label: AppStrings.todayTab,
      icon: Icons.today_rounded,
      activeIcon: Icons.today_rounded,
      screen: const TodayScreen(),
    ),
    _TabItem(
      index: 1,
      label: AppStrings.analyticsTab,
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics_rounded,
      screen: const AnalyticsScreen(),
    ),
    _TabItem(
      index: 2,
      label: AppStrings.aiCoachTab,
      icon: Icons.psychology_outlined,
      activeIcon: Icons.psychology_rounded,
      screen: const AiCoachScreen(),
    ),
    _TabItem(
      index: 3,
      label: AppStrings.profileTab,
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      screen: const ProfileScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _tabAnimations = List.generate(
      _tabs.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      ),
    );
    
    _animationController.forward();
    _tabAnimations[0].forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _tabAnimations) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    
    // Animate out previous tab
    _tabAnimations[_currentIndex].reverse();
    
    setState(() {
      _currentIndex = index;
    });
    
    // Animate in new tab
    _tabAnimations[index].forward();
    
    // Trigger scale animation for visual feedback
    _animationController.reverse().then((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return ScaleTransition(
            scale: _scaleAnimation,
            child: IndexedStack(
              index: _currentIndex,
              children: _tabs.map((tab) => tab.screen).toList(),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.glassBorder.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                final isSelected = _currentIndex == index;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onTabTapped(index),
                    child: AnimatedBuilder(
                      animation: _tabAnimations[index],
                      builder: (context, child) {
                        final scale = 0.8 + (0.2 * _tabAnimations[index].value);
                        
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSelected ? tab.activeIcon : tab.icon,
                                  color: isSelected 
                                      ? AppColors.primary
                                      : AppColors.textTertiary,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: isSelected 
                                        ? AppColors.primary
                                        : AppColors.textTertiary,
                                    fontSize: isSelected ? 12 : 11,
                                    fontWeight: isSelected 
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                  child: Text(
                                    tab.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                      .animate(
                        target: isSelected ? 1.0 : 0.0,
                      )
                      .shimmer(
                        delay: Duration(milliseconds: index * 100),
                        duration: const Duration(milliseconds: 600),
                        colors: isSelected 
                            ? [
                                Colors.transparent,
                                AppColors.primary.withOpacity(0.1),
                                Colors.transparent,
                              ]
                            : [Colors.transparent],
                      ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final int index;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget screen;

  const _TabItem({
    required this.index,
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.screen,
  });
}