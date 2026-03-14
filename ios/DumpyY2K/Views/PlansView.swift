import SwiftUI

struct PlansView: View {
    let viewModel: WorkoutViewModel
    @State private var selectedMeso: Mesocycle?

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                headerSection
                warmupCard
                mesocycleCards
                nutritionCard
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background { Y2KBackgroundGradient() }
        .sheet(item: $selectedMeso) { meso in
            MesocycleDetailSheet(mesocycle: meso, viewModel: viewModel)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text("GLUTE CLUB")
                    .font(.system(.caption, design: .rounded, weight: .black))
                    .foregroundStyle(Y2K.hotPink)
                    .tracking(2)
                Text("🍑")
            }
            Text("WEEKLY\nPROGRAMS")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(Y2K.deepGreen)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    private var warmupCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "figure.walk")
                .font(.title)
                .foregroundStyle(Y2K.limeGreen)
                .frame(width: 52, height: 52)
                .background(
                    LinearGradient(colors: [Y2K.mintGreen.opacity(0.4), Y2K.brightLime.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: Circle()
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("WARMUP: INCLINE WALK")
                    .font(.system(.subheadline, design: .rounded, weight: .black))
                    .foregroundStyle(Y2K.deepGreen)
                Text("15 min · Incline 8-12% · Speed 3.0-3.5 mph")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(Y2K.deepGreen.opacity(0.6))
            }

            Spacer()
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.9))
                .shadow(color: Y2K.limeGreen.opacity(0.1), radius: 8, y: 4)
        }
        .y2kSolidBorder(color: Y2K.limeGreen, cornerRadius: 22, lineWidth: 2.5)
    }

    private var mesocycleCards: some View {
        VStack(spacing: 16) {
            ForEach(Array(WorkoutProgramData.mesocycles.enumerated()), id: \.element.id) { index, meso in
                Button {
                    selectedMeso = meso
                } label: {
                    MesocycleCard(mesocycle: meso, index: index, isActive: viewModel.currentMesocycle?.id == meso.id)
                }
            }
        }
    }

    private var nutritionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                Text("NUTRITION TIPS")
                    .font(.system(.headline, design: .rounded, weight: .black))
                    .foregroundStyle(Y2K.deepGreen)
                Text("🥑")
            }

            NutritionRow(icon: "fork.knife", title: "Protein", detail: "0.8-1g per pound of bodyweight daily", color: Y2K.hotPink)
            NutritionRow(icon: "flame.fill", title: "Calories", detail: "Slight surplus (+200-500 cal/day)", color: Y2K.bubblegumPink)
            NutritionRow(icon: "drop.fill", title: "Hydration", detail: "Stay hydrated, don't under-eat", color: Y2K.lavender)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
        .y2kDashedBorder(color: Y2K.bubblegumPink, cornerRadius: 22)
    }
}

struct MesocycleCard: View {
    let mesocycle: Mesocycle
    let index: Int
    let isActive: Bool

    private var levelBadge: String {
        switch index {
        case 0: return "BEGINNER"
        case 1: return "INTERMEDIATE"
        case 2: return "ADVANCED"
        default: return "RECOVERY"
        }
    }

    private var borderColor: Color {
        switch index {
        case 0: return Y2K.teal
        case 1: return Y2K.deepPurple
        case 2: return Y2K.hotPink
        default: return Y2K.limeGreen
        }
    }

    private var levelColor: Color {
        switch index {
        case 0: return Y2K.limeGreen
        case 1: return Y2K.lavender
        case 2: return Y2K.hotPink
        default: return Y2K.mintGreen
        }
    }

    var body: some View {
        ZStack {
            Y2KCardGradient(style: index % 3)
                .clipShape(.rect(cornerRadius: 24))

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    if isActive {
                        Text("✦ ACTIVE")
                            .font(.system(.caption2, design: .rounded, weight: .black))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Y2K.hotPink, in: Capsule())
                    }
                    Spacer()
                    Text(levelBadge)
                        .font(.system(.caption2, design: .rounded, weight: .black))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(levelColor, in: Capsule())
                }

                Text(mesocycle.name.uppercased())
                    .font(.system(.title2, design: .rounded, weight: .black))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.15), radius: 3, y: 2)

                Text("\(mesocycle.weeks.count) WEEKS · \(mesocycle.effortLevel.displayName.uppercased())")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(.white.opacity(0.85))

                HStack(spacing: 10) {
                    InfoChip(label: "\(mesocycle.totalWorkingSets) sets")
                    InfoChip(label: mesocycle.effortLevel.emoji + " effort")
                    InfoChip(label: "Wk \(mesocycle.weeks.first ?? 0)-\(mesocycle.weeks.last ?? 0)")
                }
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)

            SparkleDecoration(size: 14, color: .white.opacity(0.6))
                .offset(x: 140, y: -60)
        }
        .frame(height: 190)
        .y2kSolidBorder(color: borderColor, cornerRadius: 24, lineWidth: 2.5)
    }
}

struct InfoChip: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.system(.caption2, design: .rounded, weight: .bold))
            .foregroundStyle(Y2K.deepGreen.opacity(0.8))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.white.opacity(0.75), in: Capsule())
    }
}

struct NutritionRow: View {
    let icon: String
    let title: String
    let detail: String
    var color: Color = Y2K.hotPink

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(color)
                .frame(width: 34, height: 34)
                .background(color.opacity(0.15), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(Y2K.deepGreen)
                Text(detail)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Y2K.deepGreen.opacity(0.6))
            }
        }
    }
}

struct MesocycleDetailSheet: View {
    let mesocycle: Mesocycle
    let viewModel: WorkoutViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    goalSection
                    exerciseBreakdown(.dayA)
                    exerciseBreakdown(.dayB)
                    progressionTips
                }
                .padding()
            }
            .background { Y2KBackgroundGradient() }
            .navigationTitle(mesocycle.name)
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

    private var goalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("GOAL")
                .font(.system(.caption, design: .rounded, weight: .black))
                .foregroundStyle(Y2K.hotPink)
                .tracking(1)
            Text(mesocycle.goal)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Y2K.deepGreen)

            HStack(spacing: 16) {
                VStack(spacing: 3) {
                    Text("\(mesocycle.totalWorkingSets)")
                        .font(.system(.title2, design: .rounded, weight: .black))
                        .foregroundStyle(Y2K.deepGreen)
                    Text("SETS/SESSION")
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(Y2K.deepGreen.opacity(0.5))
                }

                VStack(spacing: 3) {
                    Text(mesocycle.effortLevel.emoji)
                        .font(.title2)
                    Text("EFFORT")
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(Y2K.deepGreen.opacity(0.5))
                }

                VStack(spacing: 3) {
                    Text("\(mesocycle.weeks.count)")
                        .font(.system(.title2, design: .rounded, weight: .black))
                        .foregroundStyle(Y2K.deepGreen)
                    Text("WEEKS")
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(Y2K.deepGreen.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.9))
        }
        .y2kSolidBorder(color: Y2K.teal, cornerRadius: 22)
    }

    private func exerciseBreakdown(_ day: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("\(day.label.uppercased()) EXERCISES")
                .font(.system(.headline, design: .rounded, weight: .black))
                .foregroundStyle(Y2K.turquoise)

            ForEach(ExerciseCategory.allCases) { category in
                if let pair = WorkoutProgramData.exercises[category]?[day] {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(pair.primary.iconTurquoise)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            Text(pair.primary.name)
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(Y2K.turquoise)
                        }
                        Text("\(mesocycle.setsForCategory(category)) sets × \(mesocycle.repRanges[category] ?? "") · Rest \(category.restSeconds)s")
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundStyle(Y2K.turquoise.opacity(0.6))
                            .padding(.leading, 28)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.9))
        }
        .y2kDashedBorder(color: Y2K.lavender, cornerRadius: 22)
    }

    private var progressionTips: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text("HOW TO PROGRESS")
                    .font(.system(.headline, design: .rounded, weight: .black))
                    .foregroundStyle(Y2K.turquoise)
                Text("📈")
            }
            Text(mesocycle.howToProgress)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Y2K.turquoise.opacity(0.7))
                .lineSpacing(3)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.9))
        }
        .y2kSolidBorder(color: Y2K.limeGreen, cornerRadius: 22)
    }
}
