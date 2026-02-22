import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../../features/auth/domain/models/user_profile.dart';
import '../../features/auth/data/auth_repository.dart';

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  return SupabaseService.instance.authStateChanges.map((event) => event.session?.user);
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// User profile provider
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  
  try {
    return await SupabaseService.instance.getUserProfile(user.id);
  } catch (e) {
    return null;
  }
});

// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Auth notifier for managing auth state and operations
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier(this._authRepository) : super(const AsyncValue.loading()) {
    _init();
  }

  final AuthRepository _authRepository;

  void _init() {
    final currentUser = SupabaseService.instance.currentUser;
    state = AsyncValue.data(currentUser);
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authRepository.signInWithEmail(email, password);
      if (response.user != null) {
        state = AsyncValue.data(response.user);
      } else {
        throw Exception('Login failed');
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authRepository.signUpWithEmail(email, password);
      if (response.user != null) {
        state = AsyncValue.data(response.user);
      } else {
        throw Exception('Sign up failed');
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final response = await _authRepository.signInWithGoogle();
      if (response.user != null) {
        state = AsyncValue.data(response.user);
      } else {
        throw Exception('Google sign in failed');
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authRepository.resetPassword(email);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Auth notifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

// Helper providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

final isLoadingProvider = Provider<bool>((ref) {
  final authNotifierState = ref.watch(authNotifierProvider);
  final authStreamState = ref.watch(authStateProvider);
  
  return authNotifierState.isLoading || authStreamState.isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  final authNotifierState = ref.watch(authNotifierProvider);
  return authNotifierState.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
});

// User profile notifier for updating profile data
class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  UserProfileNotifier() : super(const AsyncValue.loading());

  Future<void> loadProfile(String userId) async {
    state = const AsyncValue.loading();
    try {
      final profile = await SupabaseService.instance.getUserProfile(userId);
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    try {
      await SupabaseService.instance.updateUserProfile(profile);
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final userProfileNotifierProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  return UserProfileNotifier();
});

// Settings-related providers
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
final darkModeEnabledProvider = StateProvider<bool>((ref) => true);

// Provider to watch auth state and load profile automatically
final autoLoadProfileProvider = Provider<AsyncValue<UserProfile?>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const AsyncValue.data(null);
  
  // Trigger profile load
  ref.read(userProfileNotifierProvider.notifier).loadProfile(user.id);
  
  return ref.watch(userProfileNotifierProvider);
});