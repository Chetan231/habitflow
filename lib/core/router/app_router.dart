import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/today_screen.dart';
import '../../features/habits/presentation/screens/add_habit_screen.dart';
import '../../features/habits/presentation/screens/edit_habit_screen.dart';
import '../../features/habits/presentation/screens/habit_detail_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/ai_coach/presentation/screens/ai_coach_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../shared/providers/auth_provider.dart';

// Route names
class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/';
  static const String today = '/today';
  static const String analytics = '/analytics';
  static const String aiCoach = '/ai-coach';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String addHabit = '/add-habit';
  static const String editHabit = '/edit-habit';
  static const String habitDetail = '/habit-detail';
}

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Check if user is authenticated
      final isAuthenticated = authState.when(
        data: (user) => user != null,
        loading: () => false,
        error: (_, __) => false,
      );
      
      final isOnboarding = state.uri.path == AppRoutes.onboarding;
      final isAuthRoute = state.uri.path == AppRoutes.login || state.uri.path == AppRoutes.signup;
      
      // If not authenticated and not on auth/onboarding routes, redirect to login
      if (!isAuthenticated && !isAuthRoute && !isOnboarding) {
        return AppRoutes.login;
      }
      
      // If authenticated and on auth routes, redirect to home
      if (isAuthenticated && (isAuthRoute || isOnboarding)) {
        return AppRoutes.home;
      }
      
      return null; // No redirect
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const SignUpScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return HomeScreen(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => _buildPageWithFadeTransition(
              context,
              state,
              const TodayScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.today,
            name: 'today',
            pageBuilder: (context, state) => _buildPageWithFadeTransition(
              context,
              state,
              const TodayScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.analytics,
            name: 'analytics',
            pageBuilder: (context, state) => _buildPageWithFadeTransition(
              context,
              state,
              const AnalyticsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.aiCoach,
            name: 'ai-coach',
            pageBuilder: (context, state) => _buildPageWithFadeTransition(
              context,
              state,
              const AiCoachScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (context, state) => _buildPageWithFadeTransition(
              context,
              state,
              const ProfileScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.addHabit,
        name: 'add-habit',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const AddHabitScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.editHabit}/:habitId',
        name: 'edit-habit',
        pageBuilder: (context, state) {
          final habitId = state.pathParameters['habitId']!;
          return _buildPageWithSlideTransition(
            context,
            state,
            EditHabitScreen(habitId: habitId),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.habitDetail}/:habitId',
        name: 'habit-detail',
        pageBuilder: (context, state) {
          final habitId = state.pathParameters['habitId']!;
          return _buildPageWithSlideTransition(
            context,
            state,
            HabitDetailScreen(habitId: habitId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context,
          state,
          const SettingsScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you\'re looking for doesn\'t exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Page transition builders
Page<void> _buildPageWithSlideTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).chain(
            CurveTween(curve: Curves.easeInOut),
          ),
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

Page<void> _buildPageWithFadeTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation.drive(
          CurveTween(curve: Curves.easeInOut),
        ),
        child: child,
      );
    },
  );
}

// Custom page for smooth transitions
class CustomTransitionPage<T> extends Page<T> {
  const CustomTransitionPage({
    required this.child,
    required this.transitionsBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final Duration transitionDuration;
  final Duration? reverseTransitionDuration;
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) transitionsBuilder;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration ?? transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: transitionsBuilder,
    );
  }
}

// Navigation helper extensions
extension AppRouterExtension on GoRouter {
  void goToLogin() => go(AppRoutes.login);
  void goToSignUp() => go(AppRoutes.signup);
  void goToHome() => go(AppRoutes.home);
  void goToToday() => go(AppRoutes.today);
  void goToAnalytics() => go(AppRoutes.analytics);
  void goToAICoach() => go(AppRoutes.aiCoach);
  void goToProfile() => go(AppRoutes.profile);
  void goToSettings() => go(AppRoutes.settings);
  void goToAddHabit() => push(AppRoutes.addHabit);
  void goToEditHabit(String habitId) => push('${AppRoutes.editHabit}/$habitId');
  void goToHabitDetail(String habitId) => push('${AppRoutes.habitDetail}/$habitId');
}

// Context extension for easy navigation
extension BuildContextRouterExtension on BuildContext {
  void goToLogin() => go(AppRoutes.login);
  void goToSignUp() => go(AppRoutes.signup);
  void goToHome() => go(AppRoutes.home);
  void goToToday() => go(AppRoutes.today);
  void goToAnalytics() => go(AppRoutes.analytics);
  void goToAICoach() => go(AppRoutes.aiCoach);
  void goToProfile() => go(AppRoutes.profile);
  void goToSettings() => push(AppRoutes.settings);
  void goToAddHabit() => push(AppRoutes.addHabit);
  void goToEditHabit(String habitId) => push('${AppRoutes.editHabit}/$habitId');
  void goToHabitDetail(String habitId) => push('${AppRoutes.habitDetail}/$habitId');
}