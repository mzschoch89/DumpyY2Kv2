import SwiftUI

struct HomeView: View {
    let viewModel: WorkoutViewModel
    @Binding var showWorkout: Bool
    @State private var showCalendar = false

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                headerSection
                currentWorkoutCard
                quickStatsRow
                streakCard
                prsCrushedSection
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background { Y2KBackgroundGradient() }
    }

    private var headerSection: some View {
        HStack {
            Y2KHeader(prefix: "GLUTE", accent: "Gains!", emoji: "🍑")
            Spacer()
            settingsButton
        }
        .padding(.top, 8)
    }

    private var settingsButton: some View {
        NavigationLink(destination: SettingsView()) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Y2K.hotPink, Y2K.lavender, Y2K.turquoise],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
                .overlay {
                    Circle()
                        .fill(.white)
                        .frame(width: 34, height: 34)
                        .overlay {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Y2K.hotPink)
                        }
                }
        }
    }

    private var currentWorkoutCard: some View {
        ZStack {
            Y2KCardGradient(style: 0)
                .clipShape(.rect(cornerRadius: 28))

            VStack(spacing: 16) {
                Spacer(minLength: 8)

                if let meso = viewModel.currentMesocycle {
                    let words = meso.name.uppercased().split(separator: " ")
                    VStack(spacing: 0) {
                        if words.count >= 2 {
                            Text(words.dropLast().joined(separator: " "))
                                .font(.system(size: 28, weight: .black, design: .default))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                            Text(String(words.last!))
                                .font(.system(size: 52, weight: .black, design: .default))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                        } else {
                            Text(meso.name.uppercased())
                                .font(.system(size: 36, weight: .black, design: .default))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                        }
                    }
                    .multilineTextAlignment(.center)
                    .rotationEffect(.degrees(-2.5))
                    .padding(.horizontal, 8)

                    HStack(spacing: 8) {
                        Text(meso.effortLevel.emoji)
                        Text(meso.effortLevel.displayName.uppercased())
                            .font(.system(.caption, design: .rounded, weight: .black))
                            .foregroundStyle(.white.opacity(0.9))
                        Text("·")
                            .foregroundStyle(.white.opacity(0.5))
                        Text("WEEK \(viewModel.currentWeek)")
                            .font(.system(.caption, design: .rounded, weight: .black))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }

                Button {
                    showWorkout = true
                    viewModel.startWorkout()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .symbolEffect(.bounce, value: true)
                        Text("START WORKOUT")
                            .font(.system(.headline, design: .rounded, weight: .black))
                    }
                    .foregroundStyle(Y2K.hotPink)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background {
                        Capsule()
                            .strokeBorder(Y2K.hotPink.opacity(0.5), lineWidth: 2.5)
                            .background(Capsule().fill(.white.opacity(0.9)))
                    }
                }
                .padding(.horizontal, 48)

                Text("Next: \(viewModel.nextDay.label)")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(Y2K.hotPink)

                Spacer(minLength: 8)
            }
            .padding(.vertical, 16)

            SparkleDecoration(size: 36, color: .white)
                .offset(x: -140, y: -125)
                .rotationEffect(.degrees(-15))

            SparkleDecoration(size: 28, color: .white)
                .offset(x: 148, y: -105)
                .rotationEffect(.degrees(10))

            SparkleDecoration(size: 22, color: .white)
                .offset(x: 130, y: 118)
                .rotationEffect(.degrees(-8))

            SparkleDecoration(size: 18, color: .white)
                .offset(x: -145, y: 95)
                .rotationEffect(.degrees(20))
        }
        .frame(minHeight: 320)
    }

    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            Button {
                showCalendar = true
            } label: {
                StatBubble(value: "\(viewModel.totalWorkouts)", label: "WORKOUTS", icon: "dumbbell.fill", accentColor: Y2K.hotPink)
            }
            .navigationDestination(isPresented: $showCalendar) {
                WorkoutCalendarView(viewModel: viewModel)
            }
            
            StatBubble(value: String(format: "%.1f", viewModel.totalTonsLifted), label: "TONS LIFTED", icon: "scalemass.fill", accentColor: Y2K.bubblegumPink)
            StatBubble(value: "\(viewModel.personalRecords.count)", label: "PRs", icon: "trophy.fill", accentColor: Y2K.lavender)
        }
    }

    private var streakCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("CURRENT STREAK")
                    .font(.system(.subheadline, design: .rounded, weight: .black))
                    .foregroundStyle(Y2K.hotPink)
                    .tracking(1)
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(viewModel.currentStreak)")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(Y2K.turquoise)
                    Text(viewModel.currentStreak == 0 ? "Day Streak. Let's get this party started!" : "Day Streak. Keep going baby!")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(Y2K.turquoise.opacity(0.6))
                }
            }
            Text("🔥")
                .font(.system(size: 35))
                .padding(.leading, -12)
                .offset(y: -10)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.9))
                .shadow(color: Y2K.hotPink.opacity(0.1), radius: 10, y: 5)
        }
        .y2kDashedBorder(color: Y2K.hotPink, cornerRadius: 22)
    }

    private var prsCrushedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                Text("PRs CRUSHED")
                    .font(.system(.headline, design: .rounded, weight: .black))
                    .foregroundStyle(Y2K.hotPink)
                Text("✨")
                    .font(.subheadline)
            }
            .padding(.leading, 4)
            .rotationEffect(.degrees(-2))

            if viewModel.personalRecords.isEmpty {
                HStack(spacing: 14) {
                    Image(systemName: "trophy")
                        .font(.title2)
                        .foregroundStyle(Y2K.lavender)
                        .frame(width: 44, height: 44)
                        .background(Y2K.lavender.opacity(0.15), in: Circle())

                    VStack(alignment: .leading, spacing: 3) {
                        Text("NO PRs YET")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(Y2K.turquoise.opacity(0.7))
                        Text("Start crushing workouts to set records!")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(Y2K.turquoise.opacity(0.5))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
                }
                .y2kSolidBorder(color: Y2K.lavender.opacity(0.5), cornerRadius: 18, lineWidth: 2)
            } else {
                ForEach(viewModel.personalRecords.suffix(3).reversed()) { pr in
                    PRRow(pr: pr)
                }
            }
        }
    }
}

struct StatBubble: View {
    let value: String
    let label: String
    let icon: String
    var accentColor: Color = Y2K.hotPink

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(accentColor)
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .black))
                .foregroundStyle(Y2K.turquoise)
            Text(label)
                .font(.system(.caption2, design: .rounded, weight: .bold))
                .foregroundStyle(Y2K.turquoise.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(.white.opacity(0.9))
                .shadow(color: accentColor.opacity(0.1), radius: 8, y: 4)
        }
    }
}

struct PRRow: View {
    let pr: PersonalRecord

    private var borderColors: [Color] {
        [Y2K.teal, Y2K.deepPurple, Y2K.hotPink, Y2K.limeGreen]
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "trophy.fill")
                .font(.title3)
                .foregroundStyle(Y2K.hotPink)
                .frame(width: 44, height: 44)
                .background(
                    LinearGradient(colors: [Y2K.softPink.opacity(0.4), Y2K.lavender.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: Circle()
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(pr.exerciseName.uppercased())
                    .font(.system(.subheadline, design: .rounded, weight: .black))
                    .foregroundStyle(Y2K.turquoise)
                    .lineLimit(1)
                Text(pr.date.formatted(.dateTime.month(.abbreviated).day()))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Y2K.turquoise.opacity(0.5))
            }

            Spacer()

            Text("\(Int(pr.weight)) LBS")
                .font(.system(.subheadline, design: .rounded, weight: .black))
                .foregroundStyle(Y2K.hotPink)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Y2K.softPink.opacity(0.3), in: Capsule())
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        }
        .y2kSolidBorder(color: Y2K.teal, cornerRadius: 18, lineWidth: 2)
    }
}
