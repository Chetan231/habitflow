import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import '../../../core/services/supabase_service.dart';

class AuthRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      return await _supabaseService.signInWithEmail(email, password);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      return await _supabaseService.signUpWithEmail(email, password);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      return await _supabaseService.signInWithGoogle();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabaseService.resetPassword(email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  User? get currentUser => _supabaseService.currentUser;
  
  Stream<AuthState> get authStateChanges => _supabaseService.authStateChanges;

  String _handleAuthError(dynamic error) {
    if (error is AuthException) {
      switch (error.message.toLowerCase()) {
        case 'invalid login credentials':
          return 'Invalid email or password';
        case 'email not confirmed':
          return 'Please check your email and click the confirmation link';
        case 'user not found':
          return 'No account found with this email';
        case 'weak password':
          return 'Password is too weak. Please choose a stronger password';
        case 'email already exists':
          return 'An account with this email already exists';
        case 'invalid email':
          return 'Please enter a valid email address';
        default:
          return error.message;
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }
}