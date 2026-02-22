import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? preferences;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String timezone;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    this.preferences,
    this.notificationsEnabled = true,
    this.darkModeEnabled = true,
    this.timezone = 'UTC',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    String? timezone,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      timezone: timezone ?? this.timezone,
    );
  }

  // Helper methods
  String get initials {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  String get firstName {
    final words = name.trim().split(' ');
    return words.isNotEmpty ? words.first : name;
  }

  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.avatarUrl == avatarUrl &&
        other.notificationsEnabled == notificationsEnabled &&
        other.darkModeEnabled == darkModeEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      name,
      avatarUrl,
      notificationsEnabled,
      darkModeEnabled,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, email: $email)';
  }
}