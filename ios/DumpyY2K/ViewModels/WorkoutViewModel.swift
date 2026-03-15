import SwiftUI

@Observable
@MainActor
class WorkoutViewModel {
    var currentWeek: Int = 1
    var completedSessions: [WorkoutSession] = []
    var activeSession: WorkoutSession?
    var personalRecords: [PersonalRecord] = []
    var bodyMeasurements: [BodyMeasurement] = []
    var isWorkoutActive: Bool = false
    var workoutTimer: Int = 0
    var restTimer: Int = 0
    var isResting: Bool = false
    var currentExerciseIndex: Int = 0
    var currentSetIndex: Int = 0
    var warmupShown: Bool = false

    private var timerTask: Task<Void, Never>?
    private var restTimerTask: Task<Void, Never>?

    var currentMesocycle: Mesocycle? {
        WorkoutProgramData.currentMesocycle(forWeek: currentWeek)
    }

    var nextDay: WorkoutDay {
        let completedCount = completedSessions.count
        return completedCount % 2 == 0 ? .dayA : .dayB
    }

    var totalWorkouts: Int {
        completedSessions.filter { $0.isCompleted }.count
    }

    var currentStreak: Int {
        guard !completedSessions.isEmpty else { return 0 }
        let sorted = completedSessions.filter { $0.isCompleted }.sorted { $0.date > $1.date }
        var streak = 0
        let calendar = Calendar.current
        var lastDate = Date.now

        for session in sorted {
            let daysBetween = calendar.dateComponents([.day], from: session.date, to: lastDate).day ?? 0
            if daysBetween <= 3 {
                streak += 1
                lastDate = session.date
            } else {
                break
            }
        }
        return streak
    }

    var totalTonsLifted: Double {
        completedSessions.reduce(0) { total, session in
            total + session.exerciseLogs.reduce(0) { exerciseTotal, log in
                exerciseTotal + log.sets.filter { $0.isCompleted }.reduce(0) { setTotal, set in
                    setTotal + (set.weight * Double(set.reps))
                }
            }
        } / 2000.0
    }

    func startWorkout() {
        warmupShown = false
        guard let meso = currentMesocycle else { return }
        let day = nextDay
        let exercises = WorkoutProgramData.exercisesForDay(day)

        var exerciseLogs: [ExerciseLog] = []
        for exercise in exercises {
            let setCount = meso.setsForCategory(exercise.category)
            let previousLog = lastLogForExercise(exercise.id)
            let sets = (0..<setCount).map { i in
                SetLog(
                    weight: previousLog?.sets[safe: i]?.weight ?? 0,
                    reps: 0,
                    isCompleted: false
                )
            }
            exerciseLogs.append(ExerciseLog(
                exerciseId: exercise.id,
                exerciseName: exercise.name,
                category: exercise.category,
                sets: sets
            ))
        }

        activeSession = WorkoutSession(
            week: currentWeek,
            day: day,
            mesocycleId: meso.id,
            exerciseLogs: exerciseLogs
        )
        isWorkoutActive = true
        currentExerciseIndex = 0
        currentSetIndex = 0
        workoutTimer = 0
        startTimer()
    }

    var shouldAdvanceExercise: Int?

    func completeSet(exerciseIndex: Int, setIndex: Int, weight: Double, reps: Int) {
        guard activeSession != nil else { return }
        activeSession?.exerciseLogs[exerciseIndex].sets[setIndex].weight = weight
        activeSession?.exerciseLogs[exerciseIndex].sets[setIndex].reps = reps
        activeSession?.exerciseLogs[exerciseIndex].sets[setIndex].isCompleted = true

        let category = activeSession?.exerciseLogs[exerciseIndex].category ?? .squat
        startRestTimer(seconds: category.restSeconds)

        if let log = activeSession?.exerciseLogs[exerciseIndex] {
            let isPR = checkPersonalRecord(exerciseName: log.exerciseName, weight: weight)
            if isPR, let session = activeSession, !session.prsSet.contains(log.exerciseName) {
                activeSession?.prsSet.append(log.exerciseName)
            }

            if log.sets.allSatisfy({ $0.isCompleted }) {
                if let session = activeSession {
                    let nextIndex = session.exerciseLogs.indices.first { i in
                        i > exerciseIndex && !session.exerciseLogs[i].sets.allSatisfy { $0.isCompleted }
                    }
                    if let next = nextIndex {
                        shouldAdvanceExercise = next
                    }
                }
            }
        }
    }

    func uncompleteSet(exerciseIndex: Int, setIndex: Int) {
        guard activeSession != nil else { return }
        activeSession?.exerciseLogs[exerciseIndex].sets[setIndex].isCompleted = false
    }

    func finishWorkout() {
        stopTimer()
        stopRestTimer()
        guard var session = activeSession else { return }
        session.isCompleted = true
        session.durationSeconds = workoutTimer
        completedSessions.append(session)
        activeSession = nil
        isWorkoutActive = false

        let totalSessionsNeeded = 3
        let sessionsThisWeek = completedSessions.filter { s in
            s.week == currentWeek && s.isCompleted
        }.count
        if sessionsThisWeek >= totalSessionsNeeded && currentWeek < 13 {
            currentWeek += 1
        }

        save()
    }

    func cancelWorkout() {
        stopTimer()
        stopRestTimer()
        activeSession = nil
        isWorkoutActive = false
        workoutTimer = 0
    }

    func swapExercise(at index: Int) {
        guard var session = activeSession else { return }
        let log = session.exerciseLogs[index]
        let day = session.day

        if let exercises = WorkoutProgramData.exercises[log.category]?[day] {
            let backup = log.exerciseId == exercises.primary.id ? exercises.backup : exercises.primary
            let setCount = session.exerciseLogs[index].sets.count
            let sets = (0..<setCount).map { _ in SetLog() }
            session.exerciseLogs[index] = ExerciseLog(
                exerciseId: backup.id,
                exerciseName: backup.name,
                category: backup.category,
                sets: sets
            )
            activeSession = session
        }
    }

    func startRestTimer(seconds: Int) {
        isResting = true
        restTimer = seconds
        stopRestTimer()
        restTimerTask = Task {
            while restTimer > 0 && !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if !Task.isCancelled {
                    restTimer -= 1
                }
            }
            if !Task.isCancelled {
                isResting = false
            }
        }
    }

    func skipRest() {
        stopRestTimer()
        isResting = false
        restTimer = 0
    }

    private func startTimer() {
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if !Task.isCancelled {
                    workoutTimer += 1
                }
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func stopRestTimer() {
        restTimerTask?.cancel()
        restTimerTask = nil
    }

    private func lastLogForExercise(_ exerciseId: String) -> ExerciseLog? {
        for session in completedSessions.reversed() {
            if let log = session.exerciseLogs.first(where: { $0.exerciseId == exerciseId }) {
                return log
            }
        }
        return nil
    }

    @discardableResult
    private func checkPersonalRecord(exerciseName: String, weight: Double) -> Bool {
        let currentPR = personalRecords.first { $0.exerciseName == exerciseName }
        if currentPR == nil || weight > (currentPR?.weight ?? 0) {
            personalRecords.removeAll { $0.exerciseName == exerciseName }
            personalRecords.append(PersonalRecord(exerciseName: exerciseName, weight: weight))
            return true
        }
        return false
    }

    func addMeasurement(_ measurement: BodyMeasurement) {
        bodyMeasurements.append(measurement)
        save()
    }

    var formattedTimer: String {
        let minutes = workoutTimer / 60
        let seconds = workoutTimer % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var formattedRestTimer: String {
        let minutes = restTimer / 60
        let seconds = restTimer % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func save() {
        if let data = try? JSONEncoder().encode(completedSessions) {
            UserDefaults.standard.set(data, forKey: "completedSessions")
        }
        if let data = try? JSONEncoder().encode(personalRecords) {
            UserDefaults.standard.set(data, forKey: "personalRecords")
        }
        if let data = try? JSONEncoder().encode(bodyMeasurements) {
            UserDefaults.standard.set(data, forKey: "bodyMeasurements")
        }
        UserDefaults.standard.set(currentWeek, forKey: "currentWeek")
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: "completedSessions"),
           let sessions = try? JSONDecoder().decode([WorkoutSession].self, from: data) {
            completedSessions = sessions
        }
        if let data = UserDefaults.standard.data(forKey: "personalRecords"),
           let records = try? JSONDecoder().decode([PersonalRecord].self, from: data) {
            personalRecords = records
        }
        if let data = UserDefaults.standard.data(forKey: "bodyMeasurements"),
           let measurements = try? JSONDecoder().decode([BodyMeasurement].self, from: data) {
            bodyMeasurements = measurements
        }
        let week = UserDefaults.standard.integer(forKey: "currentWeek")
        currentWeek = week > 0 ? week : 1
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
