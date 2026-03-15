import SwiftUI

struct ActiveWorkoutView: View {
    @Bindable var viewModel: WorkoutViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAbortConfirmation: Bool = false
    @State private var showEndConfirmation: Bool = false
    @State private var selectedExerciseIndex: Int = 0
    // Keys are "exerciseIndex-setIndex" to prevent cross-exercise bleed
    @State private var editingWeight: [String: String] = [:]
    @State private var editingReps: [String: String] = [:]
    @State private var showWarmup: Bool = false
    @State private var keyboardWarmedUp: Bool = false
    @State private var showWeightHelp: Bool = false
    @FocusState private var focusedField: String?
    @FocusState private var hiddenFieldFocused: Bool
    
    private var isTextFieldFocused: Bool {
        focusedField != nil
    }
    
    private var allSetsCompleted: Bool {
        guard let session = viewModel.activeSession else { return false }
        return session.exerciseLogs.allSatisfy { log in
            log.sets.allSatisfy { $0.isCompleted }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Y2KBackgroundGradient()
                
                // Hidden field for keyboard pre-warm (triggered after sheet dismisses)
                TextField("", text: .constant(""))
                    .focused($hiddenFieldFocused)
                    .frame(width: 0, height: 0)
                    .opacity(0)

                VStack(spacing: 0) {
                    if viewModel.isResting {
                        restTimerBanner
                    }
                    exerciseTabBar
                    ZStack {
                        exerciseContent
                        
                        // Top and bottom fade overlays
                        VStack {
                            // Top fade (reduced height)
                            LinearGradient(
                                colors: [Y2K.cream, Y2K.cream.opacity(0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 16)
                            
                            Spacer()
                            
                            // Bottom fade
                            LinearGradient(
                                colors: [Y2K.cream.opacity(0), Y2K.cream],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 50)
                        }
                        .allowsHitTesting(false)
                    }
                    Spacer(minLength: 0)
                    if !isTextFieldFocused {
                        bottomActions
                    }
                }
            }
            .sheet(isPresented: $showWarmup, onDismiss: {
                // Pre-warm keyboard after sheet is fully dismissed (no race)
                if !keyboardWarmedUp {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        hiddenFieldFocused = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            hiddenFieldFocused = false
                            keyboardWarmedUp = true
                        }
                    }
                }
            }) {
                warmupSheet
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .onAppear {
                if !viewModel.warmupShown {
                    showWarmup = true
                    viewModel.warmupShown = true
                }
            }
            .onChange(of: viewModel.shouldAdvanceExercise) { _, newValue in
                if let next = newValue {
                    withAnimation(.snappy) {
                        selectedExerciseIndex = next
                    }
                    viewModel.shouldAdvanceExercise = nil
                    showWeightHelp = false
                }
            }
            .onChange(of: selectedExerciseIndex) { _, _ in
                showWeightHelp = false
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showAbortConfirmation = true
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundStyle(Y2K.hotPink)
                    }
                }
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 12) {
                        Text(viewModel.activeSession?.day.label ?? "Workout")
                            .font(.system(.headline, design: .rounded, weight: .black))
                            .foregroundStyle(Y2K.turquoise)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .font(.caption)
                                .foregroundStyle(Y2K.hotPink)
                            Text(viewModel.formattedTimer)
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(Y2K.turquoise)
                                .monospacedDigit()
                                .frame(minWidth: 60)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.8), in: Capsule())
                    }
                }
            }
            .alert("Abort Workout?", isPresented: $showAbortConfirmation) {
                Button("Confirm", role: .destructive) {
                    viewModel.cancelWorkout()
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Your progress won't be saved.")
            }
            .alert("End Workout?", isPresented: $showEndConfirmation) {
                Button("End Workout", role: .destructive) {
                    viewModel.finishWorkout()
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Your progress will be saved.")
            }
        }
    }

    private var timerBar: some View {
        HStack {
            Image(systemName: "clock.fill")
                .foregroundStyle(Y2K.hotPink)
            Text(viewModel.formattedTimer)
                .font(.system(.title3, design: .rounded, weight: .black))
                .foregroundStyle(Y2K.turquoise)
                .monospacedDigit()
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.9))
    }

    private var restTimerBanner: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundStyle(.white)
            Text("REST: \(viewModel.formattedRestTimer)")
                .font(.system(.headline, design: .rounded, weight: .black))
                .foregroundStyle(.white)
                .monospacedDigit()
            Spacer()
            Button("SKIP") {
                viewModel.skipRest()
            }
            .font(.system(.caption, design: .rounded, weight: .black))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 7)
            .background(.white.opacity(0.25), in: Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            LinearGradient(colors: [Y2K.hotPink, Y2K.bubblegumPink], startPoint: .leading, endPoint: .trailing)
        )
    }

    private func isExerciseCompleted(_ log: ExerciseLog) -> Bool {
        log.sets.allSatisfy { $0.isCompleted }
    }

    private var exerciseTabBar: some View {
        HStack(spacing: 8) {
            if let session = viewModel.activeSession {
                ForEach(Array(session.exerciseLogs.enumerated()), id: \.element.id) { index, log in
                    let completed = isExerciseCompleted(log)
                    Button {
                        withAnimation(.snappy) {
                            selectedExerciseIndex = index
                        }
                    } label: {
                        VStack(spacing: 4) {
                            ZStack {
                                Image(selectedExerciseIndex == index ? log.category.customIconActive : log.category.customIconInactive)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                if completed {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(Y2K.limeGreen)
                                        .offset(x: 10, y: -8)
                                }
                            }
                            Text(log.category.displayName.uppercased())
                                .font(.system(.caption2, design: .rounded, weight: .bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .foregroundStyle(selectedExerciseIndex == index ? .white : (completed ? Y2K.limeGreen : Y2K.turquoise))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background {
                            if selectedExerciseIndex == index {
                                Capsule().fill(
                                    LinearGradient(colors: [Y2K.hotPink, Y2K.bubblegumPink], startPoint: .leading, endPoint: .trailing)
                                )
                            } else if completed {
                                Capsule().fill(Y2K.limeGreen.opacity(0.15))
                                    .overlay(Capsule().strokeBorder(Y2K.limeGreen, lineWidth: 1.5))
                            } else {
                                Capsule().fill(.white.opacity(0.9))
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 14)
    }

    @ViewBuilder
    private var exerciseContent: some View {
        if let session = viewModel.activeSession,
           session.exerciseLogs.indices.contains(selectedExerciseIndex) {
            let log = session.exerciseLogs[selectedExerciseIndex]

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        exerciseHeader(log: log)
                        setsSection(log: log, exerciseIndex: selectedExerciseIndex)
                        formTipsCard(log: log)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8) // Space below tab bar so top fade doesn't cover card
                    .padding(.bottom, 350) // Extra padding so last row can scroll above keyboard
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: focusedField) { _, newField in
                    if let field = newField {
                        // Extract the row key (e.g., "0-2-weight" -> "0-2")
                        let rowKey = field.components(separatedBy: "-").prefix(2).joined(separator: "-")
                        // Delay to let keyboard animate up first
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(rowKey, anchor: UnitPoint(x: 0.5, y: 0.3))
                            }
                        }
                    }
                }
            }
        }
    }

    private func exerciseHeader(log: ExerciseLog) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Y2KCardGradient(style: 1)
                    .clipShape(.rect(cornerRadius: 22))

                VStack(spacing: 14) {
                    Text(log.exerciseName.uppercased())
                        .font(.system(.title3, design: .rounded, weight: .black))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)

                    Image("\(log.exerciseId)-white")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .opacity(0.9)

                    if let meso = viewModel.currentMesocycle {
                        HStack(spacing: 16) {
                            MiniStat(label: "SETS", value: "\(meso.setsForCategory(log.category))")
                            MiniStat(label: "REPS", value: meso.repRanges[log.category] ?? "")
                            MiniStat(label: "EFFORT", value: meso.effortLevel.emoji)
                        }
                        
                        // Collapsible instruction box
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showWeightHelp.toggle()
                            }
                        } label: {
                            VStack(spacing: 6) {
                                if showWeightHelp {
                                    Text(meso.id == "deload" 
                                        ? "Last session's weights and reps are added as placeholders below. For this recovery week, reduce weights by ~30%."
                                        : "Last session's weights and reps are added as placeholders below. The goal is to increase last session's weight and finish all reps before adding further weight.")
                                        .font(.system(.caption2, design: .rounded, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.85))
                                        .multilineTextAlignment(.center)
                                } else {
                                    HStack(spacing: 6) {
                                        Image(systemName: "questionmark.circle")
                                            .font(.caption)
                                        Text("How to choose my weight? Tap for help!")
                                            .font(.system(.caption2, design: .rounded, weight: .medium))
                                    }
                                    .foregroundStyle(.white.opacity(0.85))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, showWeightHelp ? 10 : 8)
                            .frame(maxWidth: .infinity)
                            .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)

                SparkleDecoration(size: 14, color: .white.opacity(0.6))
                    .offset(x: 130, y: -70)
            }
            .frame(minHeight: 200)

            Button {
                viewModel.swapExercise(at: selectedExerciseIndex)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Swap Exercise")
                }
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(Y2K.hotPink)
            }
        }
    }

    private func setsSection(log: ExerciseLog, exerciseIndex: Int) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text("SET")
                    .frame(width: 36)
                Spacer()
                Text("WEIGHT")
                Spacer()
                Text("REPS")
                Spacer()
                Text("")
                    .frame(width: 80)
            }
            .font(.system(.caption, design: .rounded, weight: .bold))
            .foregroundStyle(Y2K.turquoise.opacity(0.5))
            .padding(.horizontal, 4)

            ForEach(Array(log.sets.enumerated()), id: \.element.id) { setIndex, setLog in
                let key = "\(exerciseIndex)-\(setIndex)"
                SetRow(
                    setNumber: setIndex + 1,
                    setLog: setLog,
                    isCompleted: setLog.isCompleted,
                    weightText: editingWeight[key] ?? (setLog.weight > 0 ? String(format: "%.0f", setLog.weight) : ""),
                    repsText: editingReps[key] ?? (setLog.reps > 0 ? "\(setLog.reps)" : ""),
                    onWeightChange: { editingWeight[key] = $0 },
                    onRepsChange: { editingReps[key] = $0 },
                    onToggleComplete: {
                        if setLog.isCompleted {
                            viewModel.uncompleteSet(exerciseIndex: exerciseIndex, setIndex: setIndex)
                        } else {
                            let weight = Double(editingWeight[key] ?? "") ?? setLog.weight
                            let reps = Int(editingReps[key] ?? "") ?? setLog.reps
                            viewModel.completeSet(exerciseIndex: exerciseIndex, setIndex: setIndex, weight: weight, reps: reps)
                        }
                    },
                    focusedField: $focusedField,
                    rowKey: key
                )
                .id(key)
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
        .y2kSolidBorder(color: Y2K.teal, cornerRadius: 22)
    }

    private func formTipsCard(log: ExerciseLog) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Text("PRO FORM TIPS")
                    .font(.system(.headline, design: .rounded, weight: .black))
                    .foregroundStyle(Y2K.turquoise)
                Text("✨")
            }

            let tips = getCueForExercise(log.exerciseId).components(separatedBy: ". ").filter { !$0.isEmpty }
            ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(index + 1)")
                        .font(.system(.caption, design: .rounded, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
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

    private func getCueForExercise(_ id: String) -> String {
        for (_, days) in WorkoutProgramData.exercises {
            for (_, pair) in days {
                if pair.primary.id == id { return pair.primary.cue }
                if pair.backup.id == id { return pair.backup.cue }
            }
        }
        return ""
    }

    private var bottomActions: some View {
        VStack(spacing: 10) {
            Button {
                showWarmup = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                    Text("VIEW WARMUP")
                }
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(Y2K.limeGreen)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Y2K.limeGreen.opacity(0.4), lineWidth: 1.5)
                )
            }
            
            Button {
                showEndConfirmation = true
            } label: {
                Text(allSetsCompleted ? "GREAT JOB - FINISH AND LOG SESSION" : "END WORKOUT EARLY")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(allSetsCompleted ? .white : Y2K.hotPink)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(allSetsCompleted ? 
                                  LinearGradient(colors: [Y2K.hotPink, Y2K.bubblegumPink], startPoint: .leading, endPoint: .trailing) :
                                  LinearGradient(colors: [.white.opacity(0.9), .white.opacity(0.9)], startPoint: .leading, endPoint: .trailing))
                            .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(allSetsCompleted ? Color.clear : Y2K.hotPink.opacity(0.4), lineWidth: 1.5)
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 12)
        .background {
            VStack(spacing: 0) {
                // Blur effect at top
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .mask(
                        LinearGradient(
                            colors: [.clear, .black],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 30)
                
                // Frosted glass background for buttons
                Rectangle()
                    .fill(.regularMaterial)
            }
            .ignoresSafeArea()
        }
    }

    private var warmupSheet: some View {
        VStack(spacing: 20) {
            Text("🔥")
                .font(.system(size: 48))

            Text("WARM UP FIRST!")
                .font(.system(.title2, design: .rounded, weight: .black))
                .foregroundStyle(Y2K.hotPink)

            VStack(alignment: .leading, spacing: 12) {
                warmupStep(number: 1, text: "Incline walk — 15 min · Incline 8-12% · Speed 3.0-3.5 mph")
                warmupStep(number: 2, text: "Banded glute activation — 15 clamshells each side")
                warmupStep(number: 3, text: "Bodyweight glute bridges — 2 sets of 15")
                warmupStep(number: 4, text: "Light warm-up set for your first exercise")
            }
            .padding(.horizontal, 8)

            Button {
                showWarmup = false
            } label: {
                Text("LET'S GO 💪")
                    .font(.system(.headline, design: .rounded, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [Y2K.hotPink, Y2K.bubblegumPink], startPoint: .leading, endPoint: .trailing),
                        in: Capsule()
                    )
            }
            .padding(.top, 8)
        }
        .padding(24)
    }

    private func warmupStep(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.system(.caption, design: .rounded, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(
                    LinearGradient(colors: [Y2K.hotPink, Y2K.bubblegumPink], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: Circle()
                )
            Text(text)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Y2K.turquoise)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct MiniStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(.headline, design: .rounded, weight: .black))
                .foregroundStyle(Y2K.turquoise)
            Text(label)
                .font(.system(.caption2, design: .rounded, weight: .bold))
                .foregroundStyle(Y2K.turquoise.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 14))
    }
}

struct SetRow: View {
    let setNumber: Int
    let setLog: SetLog
    let isCompleted: Bool
    let weightText: String
    let repsText: String
    let onWeightChange: (String) -> Void
    let onRepsChange: (String) -> Void
    let onToggleComplete: () -> Void
    var focusedField: FocusState<String?>.Binding
    let rowKey: String
    
    private var weightFieldKey: String { "\(rowKey)-weight" }
    private var repsFieldKey: String { "\(rowKey)-reps" }

    var body: some View {
        HStack(spacing: 10) {
            Text("\(setNumber)")
                .font(.system(.headline, design: .rounded, weight: .black))
                .foregroundStyle(isCompleted ? .white : Y2K.turquoise)
                .frame(width: 36, height: 36)
                .background {
                    Circle().fill(isCompleted ?
                        LinearGradient(colors: [Y2K.limeGreen, Y2K.brightLime], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [Y2K.cream, Y2K.cream], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                }

            TextField("0", text: Binding(
                get: { weightText },
                set: { onWeightChange($0) }
            ))
            .font(.system(.body, design: .rounded, weight: .bold))
            .foregroundStyle(Y2K.turquoise)
            .multilineTextAlignment(.center)
            .keyboardType(.decimalPad)
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .frame(minWidth: 70, minHeight: 48)
            .background(Y2K.cream, in: RoundedRectangle(cornerRadius: 12))
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .disabled(isCompleted)
            .focused(focusedField, equals: weightFieldKey)
            .onTapGesture {
                if !isCompleted {
                    focusedField.wrappedValue = weightFieldKey
                }
            }

            Text("lbs")
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(Y2K.turquoise.opacity(0.4))

            TextField("0", text: Binding(
                get: { repsText },
                set: { onRepsChange($0) }
            ))
            .font(.system(.body, design: .rounded, weight: .bold))
            .foregroundStyle(Y2K.turquoise)
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .frame(minWidth: 70, minHeight: 48)
            .background(Y2K.cream, in: RoundedRectangle(cornerRadius: 12))
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .disabled(isCompleted)
            .focused(focusedField, equals: repsFieldKey)
            .onTapGesture {
                if !isCompleted {
                    focusedField.wrappedValue = repsFieldKey
                }
            }

            Text("reps")
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(Y2K.turquoise.opacity(0.4))

            Button {
                onToggleComplete()
            } label: {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isCompleted ? Y2K.limeGreen : Y2K.hotPink.opacity(0.4))
            }
        }
        .padding(.vertical, 4)
    }
}
