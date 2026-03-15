import SwiftUI

struct WorkoutCalendarView: View {
    let viewModel: WorkoutViewModel
    @State private var selectedMonth = Date()
    @State private var selectedSession: WorkoutSession?
    
    private var calendar: Calendar {
        var cal = Calendar.current
        cal.timeZone = TimeZone.current
        return cal
    }
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                calendarCard
                statsCard
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background { Y2KBackgroundGradient() }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedSession) { session in
            WorkoutDetailSheet(session: session, viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text("DUMPY Y2K")
                    .font(.system(.caption, design: .rounded, weight: .black))
                    .foregroundStyle(Y2K.hotPink)
                    .tracking(2)
                Text("📅")
            }
            Text("WORKOUT HISTORY")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(Y2K.deepGreen)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
    
    private var calendarCard: some View {
        VStack(spacing: 16) {
            // Month Navigation
            HStack {
                Button {
                    withAnimation { changeMonth(by: -1) }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundStyle(Y2K.hotPink)
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.system(.title3, design: .rounded, weight: .black))
                    .foregroundStyle(Y2K.deepGreen)
                
                Spacer()
                
                Button {
                    withAnimation { changeMonth(by: 1) }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundStyle(Y2K.hotPink)
                        .frame(width: 44, height: 44)
                }
            }
            
            // Weekday Headers
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(weekdays.enumerated()), id: \.offset) { _, day in
                    Text(day)
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(Y2K.turquoise)
                        .frame(height: 30)
                }
            }
            
            // Calendar Days
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        DayCell(
                            date: date,
                            hasWorkout: hasWorkout(on: date),
                            isToday: calendar.isDateInToday(date),
                            onTap: {
                                print("=== DAY TAPPED ===")
                                print("Date: \(date)")
                                if let session = getSession(for: date) {
                                    print("Found session: \(session.id)")
                                    selectedSession = session
                                } else {
                                    print("NO SESSION FOUND for date")
                                }
                            }
                        )
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.9))
                .shadow(color: Y2K.lavender.opacity(0.15), radius: 12, y: 6)
        }
        .y2kDashedBorder(color: Y2K.lavender, cornerRadius: 22)
    }
    
    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("THIS MONTH")
                .font(.system(.caption, design: .rounded, weight: .black))
                .foregroundStyle(Y2K.limeGreen)
                .tracking(1.5)
            
            HStack(spacing: 20) {
                CalendarStatBubble(
                    value: "\(workoutsThisMonth)",
                    label: "Workouts",
                    color: Y2K.hotPink
                )
                
                CalendarStatBubble(
                    value: "\(prsThisMonth)",
                    label: "PRs Set",
                    color: Y2K.turquoise
                )
                
                CalendarStatBubble(
                    value: formattedTonnage,
                    label: "Total Tons",
                    color: Y2K.lavender
                )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.9))
                .shadow(color: Y2K.limeGreen.opacity(0.1), radius: 8, y: 4)
        }
        .y2kSolidBorder(color: Y2K.limeGreen, cornerRadius: 22)
    }
    
    // MARK: - Helpers
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth).uppercased()
    }
    
    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    private var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        
        // Pad to complete the last week
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private func hasWorkout(on date: Date) -> Bool {
        let result = viewModel.completedSessions.contains { session in
            calendar.isDate(session.date, inSameDayAs: date)
        }
        // Debug: print date comparisons
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        formatter.timeZone = TimeZone.current
        for session in viewModel.completedSessions {
            let match = calendar.isDate(session.date, inSameDayAs: date)
            if match || calendar.component(.day, from: date) == 14 {
                print("Comparing: cell=\(formatter.string(from: date)) vs session=\(formatter.string(from: session.date)) → \(match)")
            }
        }
        return result
    }
    
    private func getSession(for date: Date) -> WorkoutSession? {
        viewModel.completedSessions.first { session in
            calendar.isDate(session.date, inSameDayAs: date)
        }
    }
    
    private var workoutsThisMonth: Int {
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        return viewModel.completedSessions.filter { session in
            let sessionComponents = calendar.dateComponents([.year, .month], from: session.date)
            return sessionComponents.year == components.year && sessionComponents.month == components.month
        }.count
    }
    
    private var prsThisMonth: Int {
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        return viewModel.completedSessions.filter { session in
            let sessionComponents = calendar.dateComponents([.year, .month], from: session.date)
            return sessionComponents.year == components.year && sessionComponents.month == components.month
        }.reduce(0) { $0 + $1.prCount }
    }
    
    private var formattedTonnage: String {
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        let tonnage = viewModel.completedSessions.filter { session in
            let sessionComponents = calendar.dateComponents([.year, .month], from: session.date)
            return sessionComponents.year == components.year && sessionComponents.month == components.month
        }.reduce(0.0) { $0 + $1.totalTonnage } / 2000.0
        
        return String(format: "%.1f", tonnage)
    }
}

// MARK: - Day Cell

struct DayCell: View {
    let date: Date
    let hasWorkout: Bool
    let isToday: Bool
    let onTap: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                if hasWorkout {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Y2K.hotPink, Y2K.bubblegumPink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text(dayNumber)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    if isToday {
                        Circle()
                            .strokeBorder(Y2K.turquoise, lineWidth: 2)
                    }
                    
                    Text(dayNumber)
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(isToday ? Y2K.turquoise : Y2K.deepGreen.opacity(0.7))
                }
            }
            .frame(height: 44)
        }
        .disabled(!hasWorkout)
    }
}

// MARK: - Stat Bubble

struct CalendarStatBubble: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title2, design: .rounded, weight: .black))
                .foregroundStyle(color)
            
            Text(label)
                .font(.system(.caption2, design: .rounded, weight: .medium))
                .foregroundStyle(Y2K.deepGreen.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Workout Detail Sheet

struct WorkoutDetailSheet: View {
    let session: WorkoutSession
    let viewModel: WorkoutViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: session.date)
    }
    
    private var dayName: String {
        "Day \(session.day.rawValue.prefix(1).uppercased())"
    }
    
    private var prCount: Int {
        session.prsSet.count
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    VStack(spacing: 16) {
                        // Day name with emoji
                        HStack(spacing: 8) {
                            Text("🍑")
                                .font(.system(size: 32))
                            Text(dayName)
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundStyle(Y2K.hotPink)
                        }
                        
                        Text(dateString)
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundStyle(Y2K.deepGreen.opacity(0.6))
                        
                        // Stats row
                        HStack(spacing: 24) {
                            VStack(spacing: 4) {
                                Text("\(session.exerciseLogs.count)")
                                    .font(.system(.title2, design: .rounded, weight: .black))
                                    .foregroundStyle(Y2K.turquoise)
                                Text("Exercises")
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundStyle(Y2K.deepGreen.opacity(0.5))
                            }
                            
                            VStack(spacing: 4) {
                                Text("\(prCount)")
                                    .font(.system(.title2, design: .rounded, weight: .black))
                                    .foregroundStyle(Y2K.limeGreen)
                                Text("PRs")
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundStyle(Y2K.deepGreen.opacity(0.5))
                            }
                            
                            VStack(spacing: 4) {
                                Text(String(format: "%.0f", session.totalTonnage))
                                    .font(.system(.title2, design: .rounded, weight: .black))
                                    .foregroundStyle(Y2K.lavender)
                                Text("lbs lifted")
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundStyle(Y2K.deepGreen.opacity(0.5))
                            }
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .strokeBorder(Y2K.hotPink.opacity(0.3), lineWidth: 2)
                    )
                    
                    // Exercises List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("EXERCISES")
                            .font(.system(.caption, design: .rounded, weight: .black))
                            .foregroundStyle(Y2K.turquoise)
                            .tracking(1.5)
                        
                        ForEach(Array(session.exerciseLogs.enumerated()), id: \.offset) { _, log in
                            let completedSets = log.sets.filter(\.isCompleted)
                            let maxWeight = completedSets.map(\.weight).max() ?? 0
                            let totalReps = completedSets.map(\.reps).reduce(0, +)
                            let isPR = session.prsSet.contains(log.exerciseName)
                            
                            HStack(spacing: 12) {
                                // Exercise icon
                                Circle()
                                    .fill(Y2K.softPink.opacity(0.3))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: "figure.strengthtraining.traditional")
                                            .font(.system(size: 18))
                                            .foregroundStyle(Y2K.hotPink)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(log.exerciseName)
                                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                                            .foregroundStyle(Y2K.deepGreen)
                                        
                                        if isPR {
                                            Text("🏆")
                                                .font(.caption)
                                        }
                                    }
                                    
                                    Text("\(completedSets.count) sets • \(totalReps) reps • \(Int(maxWeight)) lbs")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundStyle(Y2K.deepGreen.opacity(0.6))
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .strokeBorder(Y2K.turquoise.opacity(0.3), lineWidth: 2)
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background { Y2KBackgroundGradient() }
            .navigationTitle("Workout Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(.body, design: .rounded, weight: .bold))
                        .foregroundStyle(Y2K.hotPink)
                }
            }
        }
    }
}

struct DetailPill: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(value)
                    .font(.system(.headline, design: .rounded, weight: .black))
            }
            .foregroundStyle(color)
            
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(Y2K.deepGreen.opacity(0.5))
        }
    }
}

struct CalendarExerciseRow: View {
    let exercise: CompletedExercise
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(Y2K.deepGreen)
                
                Text("\(exercise.sets) sets × \(exercise.reps) reps @ \(Int(exercise.weight)) lbs")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Y2K.deepGreen.opacity(0.6))
            }
            
            Spacer()
            
            if exercise.isPR {
                Text("🏆 PR")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(Y2K.limeGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Y2K.limeGreen.opacity(0.15), in: Capsule())
            }
        }
        .padding(.vertical, 8)
    }
}
