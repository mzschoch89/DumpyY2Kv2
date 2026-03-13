import SwiftUI

struct ExercisesView: View {
    let viewModel: WorkoutViewModel
    @State private var selectedCategory: ExerciseCategory?
    @State private var selectedExercise: Exercise?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                categoryFilter
                exercisesList
            }
            .padding(.bottom, 24)
        }
        .background { Y2KBackgroundGradient() }
        .sheet(item: $selectedExercise) { exercise in
            ExerciseDetailSheet(exercise: exercise, viewModel: viewModel)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("EXERCISE LIBRARY")
                .font(.system(.caption, design: .rounded, weight: .black))
                .foregroundStyle(Y2K.hotPink)
                .tracking(2)
            SparkleText(text: "ALL EXERCISES", font: .system(.title, design: .rounded, weight: .black))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                FilterChip(label: "ALL", isSelected: selectedCategory == nil) {
                    withAnimation(.snappy) { selectedCategory = nil }
                }
                ForEach(ExerciseCategory.allCases) { category in
                    FilterChip(label: category.displayName.uppercased(), isSelected: selectedCategory == category) {
                        withAnimation(.snappy) { selectedCategory = category }
                    }
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .scrollIndicators(.hidden)
    }

    private var exercisesList: some View {
        VStack(spacing: 12) {
            ForEach(filteredExercises, id: \.id) { exercise in
                Button {
                    selectedExercise = exercise
                } label: {
                    ExerciseRow(exercise: exercise)
                }
            }
        }
        .padding(.horizontal)
    }

    private var filteredExercises: [Exercise] {
        var result: [Exercise] = []
        let categories = selectedCategory != nil ? [selectedCategory!] : ExerciseCategory.allCases

        for category in categories {
            if let days = WorkoutProgramData.exercises[category] {
                for (_, pair) in days.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
                    if !result.contains(where: { $0.id == pair.primary.id }) {
                        result.append(pair.primary)
                    }
                    if !result.contains(where: { $0.id == pair.backup.id }) {
                        result.append(pair.backup)
                    }
                }
            }
        }
        return result
    }
}

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(isSelected ? .white : Y2K.turquoise)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background {
                    if isSelected {
                        Capsule().fill(
                            LinearGradient(colors: [Y2K.hotPink, Y2K.bubblegumPink], startPoint: .leading, endPoint: .trailing)
                        )
                    } else {
                        Capsule().fill(.white.opacity(0.9))
                            .shadow(color: Y2K.hotPink.opacity(0.08), radius: 4, y: 2)
                    }
                }
        }
    }
}

struct ExerciseRow: View {
    let exercise: Exercise

    private var borderColor: Color {
        switch exercise.category {
        case .squat: return Y2K.teal
        case .hinge: return Y2K.deepPurple
        case .bridge: return Y2K.hotPink
        case .abduction: return Y2K.limeGreen
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: exercise.category.icon)
                .font(.title3)
                .foregroundStyle(borderColor)
                .frame(width: 48, height: 48)
                .background(borderColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 5) {
                Text(exercise.name.uppercased())
                    .font(.system(.subheadline, design: .rounded, weight: .black))
                    .foregroundStyle(Y2K.turquoise)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(exercise.category.displayName)
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(borderColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(borderColor.opacity(0.12), in: Capsule())

                    if exercise.isBackup {
                        Text("BACKUP")
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                            .foregroundStyle(Y2K.limeGreen)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Y2K.mintGreen.opacity(0.2), in: Capsule())
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(borderColor.opacity(0.5))
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        }
        .y2kSolidBorder(color: borderColor.opacity(0.4), cornerRadius: 20, lineWidth: 2)
    }
}

struct ExerciseDetailSheet: View {
    let exercise: Exercise
    let viewModel: WorkoutViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    heroCard
                    statsSection
                    cueSection
                }
                .padding()
            }
            .background { Y2KBackgroundGradient() }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundStyle(Y2K.hotPink)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("EXERCISE DETAIL")
                        .font(.system(.caption, design: .rounded, weight: .black))
                        .foregroundStyle(Y2K.hotPink)
                        .tracking(1.5)
                }
            }
        }
    }

    private var heroCard: some View {
        ZStack {
            Y2KCardGradient(style: exercise.category == .squat || exercise.category == .hinge ? 0 : 1)
                .clipShape(.rect(cornerRadius: 24))

            VStack(spacing: 16) {
                Text(exercise.name.uppercased())
                    .font(.system(.title2, design: .rounded, weight: .black))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
                    .multilineTextAlignment(.center)

                Image(systemName: exercise.category.icon)
                    .font(.system(size: 44))
                    .foregroundStyle(.white.opacity(0.7))

                Text(exercise.category.displayName.uppercased())
                    .font(.system(.caption, design: .rounded, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 7)
                    .background(.white.opacity(0.25), in: Capsule())
            }
            .padding(28)

            SparkleDecoration(size: 16, color: .white.opacity(0.7))
                .offset(x: 130, y: -90)
            SparkleDecoration(size: 12, color: Y2K.brightYellow.opacity(0.8))
                .offset(x: -120, y: -80)
        }
        .frame(height: 260)
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("PROGRAM INFO")
                .font(.system(.headline, design: .rounded, weight: .black))
                .foregroundStyle(Y2K.turquoise)

            if let meso = viewModel.currentMesocycle {
                HStack(spacing: 12) {
                    MiniStat(label: "SETS", value: "\(meso.setsForCategory(exercise.category))")
                    MiniStat(label: "REPS", value: meso.repRanges[exercise.category] ?? "")
                    MiniStat(label: "REST", value: "\(exercise.category.restSeconds)s")
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
        .y2kSolidBorder(color: Y2K.teal, cornerRadius: 22)
    }

    private var cueSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Text("PRO FORM TIPS")
                    .font(.system(.headline, design: .rounded, weight: .black))
                    .foregroundStyle(Y2K.turquoise)
                Text("✨")
            }

            let tips = exercise.cue.components(separatedBy: ". ").filter { !$0.isEmpty }
            ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.system(.caption, design: .rounded, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: 26, height: 26)
                        .background(
                            LinearGradient(colors: [Y2K.limeGreen, Y2K.brightLime], startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: Circle()
                        )

                    Text(tip.trimmingCharacters(in: .punctuationCharacters).trimmingCharacters(in: .whitespaces))
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Y2K.turquoise.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
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
        .y2kDashedBorder(color: Y2K.limeGreen, cornerRadius: 22)
    }
}
