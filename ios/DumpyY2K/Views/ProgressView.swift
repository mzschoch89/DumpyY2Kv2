import SwiftUI

struct ProgressTabView: View {
    @Bindable var viewModel: WorkoutViewModel
    @State private var showMeasurementSheet: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                bodyStatsCard
                weekProgressBar
                personalRecordsSection
                milestonesSection
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background { Y2KBackgroundGradient() }
        .sheet(isPresented: $showMeasurementSheet) {
            MeasurementSheet(viewModel: viewModel)
        }
    }

    private var headerSection: some View {
        HStack {
            Y2KHeader(prefix: "YOUR", accent: "Progress", emoji: "✨")
            Spacer()
            Button {
                showMeasurementSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(Y2K.hotPink, in: Circle())
            }
        }
        .padding(.top, 8)
    }

    private var bodyStatsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("BODY STATS")
                .font(.system(.caption, design: .rounded, weight: .black))
                .foregroundStyle(Y2K.hotPink)
                .tracking(1.5)

            if let latest = viewModel.bodyMeasurements.last {
                MeasurementRow(label: "GLUTES", value: String(format: "%.1f\"", latest.glutes), icon: "circle.fill", color: Y2K.hotPink)
                MeasurementRow(label: "WAIST", value: String(format: "%.1f\"", latest.waist), icon: "circle.fill", color: Y2K.limeGreen)
                MeasurementRow(label: "THIGHS", value: String(format: "%.1f\"", latest.thighs), icon: "circle.fill", color: Y2K.lavender)
            } else {
                Text("Tap + to add your first measurement")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Y2K.turquoise.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.9))
                .shadow(color: Y2K.hotPink.opacity(0.08), radius: 8, y: 4)
        }
        .y2kDashedBorder(color: Y2K.hotPink, cornerRadius: 22)
    }

    private var weekProgressBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("PROGRAM PROGRESS")
                    .font(.system(.caption, design: .rounded, weight: .black))
                    .foregroundStyle(Y2K.hotPink)
                    .tracking(1)
                Spacer()
                Text("Week \(viewModel.currentWeek)/13")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(Y2K.turquoise)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Y2K.cream)
                        .frame(height: 14)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Y2K.hotPink, Y2K.bubblegumPink, Y2K.limeGreen],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(viewModel.currentWeek) / 13.0, height: 14)
                }
            }
            .frame(height: 14)

            HStack {
                ForEach(WorkoutProgramData.mesocycles, id: \.id) { meso in
                    Text(meso.name)
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(viewModel.currentMesocycle?.id == meso.id ? Y2K.hotPink : Y2K.turquoise.opacity(0.3))
                    if meso.id != "deload" {
                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
        .y2kSolidBorder(color: Y2K.teal, cornerRadius: 22)
    }

    private var personalRecordsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Text("PERSONAL RECORDS")
                    .font(.system(.headline, design: .rounded, weight: .black))
                    .foregroundStyle(Y2K.turquoise)
                Text("🏆")
            }

            if viewModel.personalRecords.isEmpty {
                HStack {
                    Image(systemName: "trophy")
                        .foregroundStyle(Y2K.lavender)
                    Text("Complete workouts to set PRs!")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(Y2K.turquoise.opacity(0.5))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 14)
            } else {
                ForEach(viewModel.personalRecords) { pr in
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(Y2K.hotPink)
                        Text(pr.exerciseName.uppercased())
                            .font(.system(.subheadline, design: .rounded, weight: .black))
                            .foregroundStyle(Y2K.turquoise)
                        Spacer()
                        Text("\(Int(pr.weight)) LBS")
                            .font(.system(.subheadline, design: .rounded, weight: .black))
                            .foregroundStyle(Y2K.hotPink)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Y2K.softPink.opacity(0.3), in: Capsule())
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
        .y2kDashedBorder(color: Y2K.deepPurple, cornerRadius: 22)
    }

    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Text("MILESTONES")
                    .font(.system(.headline, design: .rounded, weight: .black))
                    .foregroundStyle(Y2K.hotPink)
                Text("✨")
                    .font(.subheadline)
            }

            ScrollView(.horizontal) {
                HStack(spacing: 14) {
                    MilestoneBadge(icon: "star.fill", title: "Glute Starter", subtitle: "First workout", isUnlocked: viewModel.totalWorkouts >= 1)
                    MilestoneBadge(icon: "flame.fill", title: "7-Day Streak", subtitle: "3 workouts in a row", isUnlocked: viewModel.currentStreak >= 3)
                    MilestoneBadge(icon: "bolt.fill", title: "Heavy Hitter", subtitle: "10 workouts done", isUnlocked: viewModel.totalWorkouts >= 10)
                    MilestoneBadge(icon: "crown.fill", title: "Elite Glutes", subtitle: "All 13 weeks done", isUnlocked: viewModel.currentWeek > 13)
                }
            }
            .contentMargins(.horizontal, 0)
            .scrollIndicators(.hidden)
        }
    }
}

struct MeasurementRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(Y2K.turquoise)
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .black))
                .foregroundStyle(Y2K.turquoise)
        }
    }
}

struct MilestoneBadge: View {
    let icon: String
    let title: String
    let subtitle: String
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(isUnlocked ?
                        LinearGradient(colors: [Y2K.hotPink, Y2K.bubblegumPink, Y2K.lavender], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [Color.gray.opacity(0.15), Color.gray.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 64, height: 64)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(isUnlocked ? .white : .gray.opacity(0.35))
            }

            Text(title)
                .font(.system(.caption2, design: .rounded, weight: .bold))
                .foregroundStyle(isUnlocked ? Y2K.turquoise : Y2K.turquoise.opacity(0.3))
                .multilineTextAlignment(.center)
        }
        .frame(width: 85)
    }
}

struct MeasurementSheet: View {
    let viewModel: WorkoutViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var glutes: String = ""
    @State private var waist: String = ""
    @State private var thighs: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    MeasurementInput(label: "GLUTES", placeholder: "e.g. 38.5", text: $glutes, color: Y2K.hotPink)
                    MeasurementInput(label: "WAIST", placeholder: "e.g. 26.0", text: $waist, color: Y2K.limeGreen)
                    MeasurementInput(label: "THIGHS", placeholder: "e.g. 22.5", text: $thighs, color: Y2K.lavender)
                }
                .padding(20)

                Text("Measure in inches for consistency")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Y2K.turquoise.opacity(0.5))

                Spacer()
            }
            .background { Y2KBackgroundGradient() }
            .navigationTitle("Add Measurement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Y2K.hotPink)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let measurement = BodyMeasurement(
                            glutes: Double(glutes) ?? 0,
                            waist: Double(waist) ?? 0,
                            thighs: Double(thighs) ?? 0
                        )
                        viewModel.addMeasurement(measurement)
                        dismiss()
                    }
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .foregroundStyle(Y2K.hotPink)
                    .disabled(glutes.isEmpty && waist.isEmpty && thighs.isEmpty)
                }
            }
        }
    }
}

struct MeasurementInput: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(Y2K.turquoise)
            Spacer()
            TextField(placeholder, text: $text)
                .font(.system(.body, design: .rounded, weight: .bold))
                .foregroundStyle(Y2K.turquoise)
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
                .frame(width: 100)
            Text("in")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(Y2K.turquoise.opacity(0.5))
        }
        .padding(16)
        .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 16))
    }
}
