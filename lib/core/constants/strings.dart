class AppStrings {
  // App Info
  static const String appName = 'HabitFlow';
  static const String appTagline = 'Flow into better habits';
  
  // Configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String openAiApiKey = 'YOUR_OPENAI_API_KEY';
  
  // Authentication
  static const String welcomeTitle = 'Welcome to HabitFlow';
  static const String welcomeSubtitle = 'Build lasting habits with AI-powered insights';
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Continue your habit journey';
  static const String signUpTitle = 'Create Account';
  static const String signUpSubtitle = 'Start building better habits today';
  static const String emailHint = 'Enter your email';
  static const String passwordHint = 'Enter your password';
  static const String confirmPasswordHint = 'Confirm your password';
  static const String loginButton = 'Sign In';
  static const String signUpButton = 'Create Account';
  static const String googleSignIn = 'Continue with Google';
  static const String forgotPassword = 'Forgot Password?';
  static const String noAccount = 'Don\'t have an account? ';
  static const String haveAccount = 'Already have an account? ';
  static const String signUpLink = 'Sign Up';
  static const String signInLink = 'Sign In';
  
  // Onboarding
  static const String onboardingTitle1 = 'Track Daily Habits';
  static const String onboardingSubtitle1 = 'Build consistency with simple, daily habit tracking';
  static const String onboardingTitle2 = 'AI-Powered Insights';
  static const String onboardingSubtitle2 = 'Get personalized coaching and motivation from AI';
  static const String onboardingTitle3 = 'Visualize Progress';
  static const String onboardingSubtitle3 = 'See your growth with beautiful charts and analytics';
  static const String skip = 'Skip';
  static const String next = 'Next';
  static const String getStarted = 'Get Started';
  
  // Navigation
  static const String todayTab = 'Today';
  static const String analyticsTab = 'Analytics';
  static const String aiCoachTab = 'AI Coach';
  static const String profileTab = 'Profile';
  
  // Today Screen
  static const String todayTitle = 'Today';
  static const String goodMorning = 'Good morning';
  static const String goodAfternoon = 'Good afternoon';
  static const String goodEvening = 'Good evening';
  static const String dailyProgress = 'Daily Progress';
  static const String todayHabits = 'Today\'s Habits';
  static const String noHabitsToday = 'No habits scheduled for today';
  static const String addFirstHabit = 'Add your first habit';
  static const String completed = 'Completed';
  static const String remaining = 'Remaining';
  
  // Habits
  static const String addHabit = 'Add Habit';
  static const String editHabit = 'Edit Habit';
  static const String habitName = 'Habit Name';
  static const String habitNameHint = 'e.g., Drink 8 glasses of water';
  static const String habitType = 'Habit Type';
  static const String yesNo = 'Yes/No';
  static const String count = 'Count';
  static const String time = 'Time';
  static const String targetValue = 'Target Value';
  static const String unit = 'Unit';
  static const String frequency = 'Frequency';
  static const String reminderTime = 'Reminder Time';
  static const String chooseIcon = 'Choose Icon';
  static const String chooseColor = 'Choose Color';
  static const String saveHabit = 'Save Habit';
  static const String deleteHabit = 'Delete Habit';
  static const String archiveHabit = 'Archive Habit';
  static const String restoreHabit = 'Restore Habit';
  
  // Days of Week
  static const String monday = 'Mon';
  static const String tuesday = 'Tue';
  static const String wednesday = 'Wed';
  static const String thursday = 'Thu';
  static const String friday = 'Fri';
  static const String saturday = 'Sat';
  static const String sunday = 'Sun';
  
  // Analytics
  static const String analyticsTitle = 'Analytics';
  static const String daily = 'Daily';
  static const String weekly = 'Weekly';
  static const String monthly = 'Monthly';
  static const String streaks = 'Streaks';
  static const String bestHabits = 'Best Habits';
  static const String improvementAreas = 'Areas for Improvement';
  static const String completionRate = 'Completion Rate';
  static const String currentStreak = 'Current Streak';
  static const String longestStreak = 'Longest Streak';
  static const String totalDays = 'Total Days';
  
  // AI Coach
  static const String aiCoachTitle = 'AI Coach';
  static const String dailyMotivation = 'Daily Motivation';
  static const String weeklySummary = 'Weekly Summary';
  static const String suggestions = 'Suggestions';
  static const String insights = 'Insights';
  static const String loadingMotivation = 'Getting your daily motivation...';
  static const String loadingSummary = 'Analyzing your progress...';
  static const String motivationError = 'Unable to load motivation. Try again later.';
  
  // Profile
  static const String profileTitle = 'Profile';
  static const String settings = 'Settings';
  static const String statistics = 'Statistics';
  static const String totalHabits = 'Total Habits';
  static const String activeStreaks = 'Active Streaks';
  static const String perfectDays = 'Perfect Days';
  static const String signOut = 'Sign Out';
  
  // Settings
  static const String settingsTitle = 'Settings';
  static const String notifications = 'Notifications';
  static const String enableNotifications = 'Enable Notifications';
  static const String darkMode = 'Dark Mode';
  static const String backupRestore = 'Backup & Restore';
  static const String exportData = 'Export Data';
  static const String importData = 'Import Data';
  static const String deleteAccount = 'Delete Account';
  static const String about = 'About';
  static const String version = 'Version';
  static const String privacy = 'Privacy Policy';
  static const String terms = 'Terms of Service';
  
  // Error Messages
  static const String emailRequired = 'Email is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordsMismatch = 'Passwords do not match';
  static const String loginFailed = 'Login failed. Please try again.';
  static const String signUpFailed = 'Sign up failed. Please try again.';
  static const String habitNameRequired = 'Habit name is required';
  static const String networkError = 'Network error. Please check your connection.';
  static const String genericError = 'Something went wrong. Please try again.';
  
  // Success Messages
  static const String loginSuccess = 'Welcome back!';
  static const String signUpSuccess = 'Account created successfully!';
  static const String habitAdded = 'Habit added successfully!';
  static const String habitUpdated = 'Habit updated successfully!';
  static const String habitDeleted = 'Habit deleted successfully!';
  static const String habitCompleted = 'Great job! Habit completed!';
  
  // Actions
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String retry = 'Retry';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String done = 'Done';
  
  // Time
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String thisWeek = 'This Week';
  static const String lastWeek = 'Last Week';
  static const String thisMonth = 'This Month';
  static const String lastMonth = 'Last Month';
  
  // Units
  static const String times = 'times';
  static const String minutes = 'minutes';
  static const String hours = 'hours';
  static const String glasses = 'glasses';
  static const String pages = 'pages';
  static const String kilometers = 'km';
  static const String steps = 'steps';
}