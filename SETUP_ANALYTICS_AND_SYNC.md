# DumpyY2K Analytics & Cloud Sync Setup

## 1. TelemetryDeck Setup

1. Go to https://dashboard.telemetrydeck.com
2. Create a new app or use existing
3. Copy the App ID
4. Update `AnalyticsService.swift`:
   ```swift
   private let telemetryDeckAppID = "YOUR_APP_ID_HERE"
   ```

### Add SPM Package in Xcode:
1. File → Add Package Dependencies
2. URL: `https://github.com/TelemetryDeck/SwiftClient`
3. Add to DumpyY2K target

---

## 2. AppsFlyer Setup

1. Go to https://hq.appsflyer.com
2. Add your app (need App Store Connect listing first)
3. Get your Dev Key from Settings → Dev Key
4. Get your Apple App ID from App Store Connect
5. Update `AnalyticsService.swift`:
   ```swift
   private let appsFlyerDevKey = "YOUR_DEV_KEY"
   private let appsFlyerAppID = "123456789" // Numeric App Store ID
   ```

### Add SPM Package in Xcode:
1. File → Add Package Dependencies
2. URL: `https://github.com/AppsFlyerSDK/AppsFlyerFramework`
3. Add to DumpyY2K target

---

## 3. Initialize Analytics in App

Update `DumpyY2KApp.swift`:

```swift
import SwiftUI

@main
struct DumpyY2KApp: App {
    init() {
        AnalyticsService.shared.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .onAppear {
                    AnalyticsService.shared.trackAppLaunched()
                    AnalyticsService.shared.startAppsFlyer()
                }
        }
    }
}
```

---

## 4. Supabase Database Setup

Run this SQL in your Supabase SQL Editor:

```sql
-- Workouts table
CREATE TABLE IF NOT EXISTS workouts (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date TIMESTAMPTZ NOT NULL,
    week INTEGER NOT NULL,
    day TEXT NOT NULL,
    mesocycle_id TEXT NOT NULL,
    exercise_logs JSONB NOT NULL DEFAULT '[]',
    is_completed BOOLEAN DEFAULT FALSE,
    duration_seconds INTEGER DEFAULT 0,
    prs_set TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Personal records table
CREATE TABLE IF NOT EXISTS personal_records (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    exercise_name TEXT NOT NULL,
    weight DOUBLE PRECISION NOT NULL,
    date TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add current_week to user_profiles if not exists
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS current_week INTEGER DEFAULT 1;

-- Enable Row Level Security
ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE personal_records ENABLE ROW LEVEL SECURITY;

-- RLS Policies for workouts
CREATE POLICY "Users can view own workouts" ON workouts
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own workouts" ON workouts
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own workouts" ON workouts
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own workouts" ON workouts
    FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for personal_records
CREATE POLICY "Users can view own PRs" ON personal_records
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own PRs" ON personal_records
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own PRs" ON personal_records
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own PRs" ON personal_records
    FOR DELETE USING (auth.uid() = user_id);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS workouts_user_id_idx ON workouts(user_id);
CREATE INDEX IF NOT EXISTS workouts_date_idx ON workouts(date DESC);
CREATE INDEX IF NOT EXISTS personal_records_user_id_idx ON personal_records(user_id);
```

---

## 5. Add Supabase SPM Package

If not already added:
1. File → Add Package Dependencies
2. URL: `https://github.com/supabase/supabase-swift`
3. Add `Supabase` to DumpyY2K target

---

## Quick Checklist

- [ ] TelemetryDeck App ID in AnalyticsService.swift
- [ ] TelemetryDeck SPM package added
- [ ] AppsFlyer Dev Key in AnalyticsService.swift
- [ ] AppsFlyer App ID in AnalyticsService.swift
- [ ] AppsFlyer SPM package added
- [ ] Analytics initialized in DumpyY2KApp.swift
- [ ] Supabase SQL tables created
- [ ] Supabase SPM package added
