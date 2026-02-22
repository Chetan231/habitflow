# HabitFlow - Smart Habit Tracker 🎯

Ek complete habit tracking app with AI coaching, streaks, aur gamification! Built with Flutter aur Supabase.

## Features ✨

- **Habit Tracking**: Daily, weekly, ya custom frequency
- **AI Coach**: Personalized motivation aur insights (Hinglish mein!)
- **Streaks & Badges**: Gamification for motivation
- **Clean UI**: Modern Material Design
- **Offline Support**: Local storage with sync
- **Cross Platform**: Android & iOS ready

## Prerequisites 📋

Ye sab cheezein installed honi chahiye:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0+)
- [Git](https://git-scm.com/)
- Android Studio / VS Code
- [Supabase Account](https://supabase.com/)
- [OpenAI API Key](https://platform.openai.com/)

## Quick Setup 🚀

### Step 1: Clone aur Install

```bash
git clone <your-repo-url> habitflow
cd habitflow
flutter pub get
```

### Step 2: Supabase Setup

1. **New Project banayein**: [Supabase Dashboard](https://app.supabase.com/) pe jaake
2. **Database Migration**:
   ```bash
   # Supabase CLI install karein
   npm install -g supabase
   
   # Login karein
   supabase login
   
   # Project link karein
   supabase link --project-ref YOUR_PROJECT_ID
   
   # Migration run karein
   supabase db push
   ```

3. **Authentication Setup**:
   - Dashboard → Authentication → Providers
   - Google provider enable karein
   - OAuth credentials add karein

4. **Edge Functions Deploy**:
   ```bash
   # AI Coach function
   supabase functions deploy ai-coach
   
   # Weekly Summary function  
   supabase functions deploy weekly-summary
   ```

5. **Environment Variables**:
   - Dashboard → Settings → API
   - SUPABASE_URL aur SUPABASE_SERVICE_ROLE_KEY copy karein
   - Functions → Edge Functions → Settings mein OPENAI_API_KEY add karein

### Step 3: App Configuration

`lib/config/constants.dart` file mein ye values update karein:

```dart
// Supabase Configuration
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

// OpenAI Configuration (Optional - edge functions use karte hain)
static const String openaiApiKey = 'YOUR_OPENAI_API_KEY';
```

### Step 4: Run the App

```bash
# Development mode
flutter run

# Debug build
flutter run --debug

# Release build (Android)
flutter run --release
```

## Production Build 📱

### Android (Play Store)

```bash
# App bundle banayein
flutter build appbundle

# APK banayein (testing ke liye)
flutter build apk --release
```

### iOS (App Store)

```bash
# iOS build
flutter build ipa

# Xcode mein open karke Archive karein
open ios/Runner.xcworkspace
```

## Project Structure 📁

```
habitflow/
├── lib/
│   ├── config/           # App constants aur configuration
│   ├── models/           # Data models (Habit, Entry, etc.)
│   ├── screens/          # UI screens
│   ├── services/         # Supabase, AI, storage services
│   ├── widgets/          # Reusable widgets
│   └── main.dart         # App entry point
├── supabase/
│   ├── migrations/       # Database schema
│   └── functions/        # Edge functions (AI coach)
├── assets/               # Images, fonts, etc.
└── test/                 # Unit tests
```

## Environment Variables 🔧

Development ke liye `.env` file banayein:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
OPENAI_API_KEY=your_openai_key
```

Production mein ye environment variables set karein:
- Google Play Console → App Bundle Explorer → Environment Variables
- iOS: Xcode → Build Settings → User-Defined Settings

## Key Features Detail 🔍

### AI Coach
- Daily motivation messages (Hinglish mein!)
- Weekly summary with insights
- Pattern detection aur suggestions
- OpenAI GPT-4o-mini powered

### Habit Types
- **Boolean**: Simple Yes/No (exercise, meditation)
- **Count**: Numerical tracking (glasses of water, pushups)
- **Time**: Duration tracking (reading, study time)

### Gamification
- Streak tracking (current aur longest)
- Badge system (10 different badges)
- XP points aur levels
- Leaderboard (future feature)

## Troubleshooting 🔧

### Common Issues

**1. Supabase Connection Failed**
```bash
# Check internet connection
# Verify SUPABASE_URL aur ANON_KEY
# Dashboard mein project status check karein
```

**2. AI Coach Not Working**
```bash
# Edge functions deploy check karein
supabase functions list

# Logs check karein  
supabase functions logs ai-coach
```

**3. Build Errors**
```bash
# Clean build
flutter clean
flutter pub get

# Dependencies update
flutter pub upgrade
```

**4. Android Build Issues**
```bash
# Gradle wrapper permissions
cd android
chmod +x gradlew
./gradlew clean

# Back to root
cd ..
flutter build apk
```

**5. iOS Build Issues**
```bash
# Pods clean
cd ios
rm -rf Pods/ .symlinks/ Flutter/Flutter.framework
pod install

# Back to root
cd ..
flutter build ios
```

### Debug Commands

```bash
# Device check
flutter devices

# Doctor check  
flutter doctor -v

# Dependency tree
flutter pub deps

# Analysis
flutter analyze

# Test run
flutter test
```

## Performance Tips 🚀

1. **Image Optimization**: Assets ko compress karein
2. **Bundle Size**: Unused dependencies remove karein
3. **Database**: Efficient queries use karein
4. **Caching**: AI insights cache karein
5. **Offline**: Sqlite local storage implement karein

## Contributing 🤝

1. Fork the repository
2. Feature branch banayein (`git checkout -b feature/amazing-feature`)
3. Changes commit karein (`git commit -m 'Add amazing feature'`)
4. Branch push karein (`git push origin feature/amazing-feature`)
5. Pull Request open karein

## Support 💬

Issues ya questions ke liye:
- GitHub Issues create karein
- Documentation check karein
- Community Discord join karein

## License 📄

This project is licensed under the MIT License.

---

**Happy Habit Building! 🎯💪**

Made with ❤️ for the Indian developer community!