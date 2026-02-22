-- Profiles (extends Supabase auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  avatar_url TEXT,
  timezone TEXT DEFAULT 'Asia/Kolkata',
  streak_best INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  xp INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Habits
CREATE TABLE habits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  icon TEXT DEFAULT '⭐',
  color TEXT DEFAULT '#6C63FF',
  habit_type TEXT CHECK (habit_type IN ('boolean', 'count', 'time')) DEFAULT 'boolean',
  target_value INTEGER DEFAULT 1,
  unit TEXT DEFAULT '',
  frequency TEXT CHECK (frequency IN ('daily', 'weekly', 'custom')) DEFAULT 'daily',
  frequency_days INTEGER[] DEFAULT '{1,2,3,4,5,6,7}',
  reminder_enabled BOOLEAN DEFAULT false,
  reminder_time TIME,
  position INTEGER DEFAULT 0,
  is_archived BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Habit Entries (daily tracking)
CREATE TABLE habit_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  habit_id UUID REFERENCES habits(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  completed BOOLEAN DEFAULT false,
  value NUMERIC DEFAULT 0,
  notes TEXT,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(habit_id, date)
);

-- Streaks (pre-calculated)
CREATE TABLE streaks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  habit_id UUID REFERENCES habits(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_completed_date DATE,
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(habit_id)
);

-- AI Insights cache
CREATE TABLE ai_insights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  insight_type TEXT CHECK (insight_type IN ('daily_motivation', 'weekly_summary', 'suggestion', 'pattern')),
  content JSONB NOT NULL,
  date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Badges
CREATE TABLE badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  requirement_type TEXT,
  requirement_value INTEGER
);

CREATE TABLE user_badges (
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  badge_id UUID REFERENCES badges(id),
  earned_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (user_id, badge_id)
);

-- Indexes
CREATE INDEX idx_entries_user_date ON habit_entries(user_id, date);
CREATE INDEX idx_entries_habit_date ON habit_entries(habit_id, date);
CREATE INDEX idx_habits_user ON habits(user_id);
CREATE INDEX idx_insights_user_type ON ai_insights(user_id, insight_type);
CREATE INDEX idx_streaks_user ON streaks(user_id);

-- Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE habit_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can CRUD own habits" ON habits FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can CRUD own entries" ON habit_entries FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can CRUD own streaks" ON streaks FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can CRUD own insights" ON ai_insights FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can view own badges" ON user_badges FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can earn badges" ON user_badges FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Anyone can view badges" ON badges FOR SELECT TO authenticated USING (true);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER habits_updated_at BEFORE UPDATE ON habits FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER streaks_updated_at BEFORE UPDATE ON streaks FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Seed badges
INSERT INTO badges (name, description, icon, requirement_type, requirement_value) VALUES
  ('First Step', 'Complete your first habit', '🌱', 'total', 1),
  ('Week Warrior', '7-day streak', '⚔️', 'streak', 7),
  ('Monthly Master', '30-day streak', '👑', 'streak', 30),
  ('Century Club', '100-day streak', '💯', 'streak', 100),
  ('Perfect Day', 'Complete all habits in a day', '⭐', 'perfect_day', 1),
  ('Perfect Week', '7 perfect days in a row', '🏆', 'perfect_week', 7),
  ('Habit Builder', 'Create 5 habits', '🏗️', 'habit_count', 5),
  ('Habit Master', 'Create 10 habits', '🎯', 'habit_count', 10),
  ('Early Bird', 'Complete a habit before 7 AM', '🐦', 'early', 1),
  ('Night Owl', 'Complete a habit after 11 PM', '🦉', 'late', 1);