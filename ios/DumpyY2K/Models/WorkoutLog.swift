import Foundation

nonisolated struct SetLog: Identifiable, Codable, Sendable {
    let id: UUID
    var weight: Double
    var reps: Int
    var isCompleted: Bool

    init(id: UUID = UUID(), weight: Double = 0, reps: Int = 0, isCompleted: Bool = false) {
        self.id = id
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
    }
}

nonisolated struct ExerciseLog: Identifiable, Codable, Sendable {
    let id: UUID
    let exerciseId: String
    let exerciseName: String
    let category: ExerciseCategory
    var sets: [SetLog]

    init(id: UUID = UUID(), exerciseId: String, exerciseName: String, category: ExerciseCategory, sets: [SetLog]) {
        self.id = id
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.category = category
        self.sets = sets
    }
}

nonisolated struct WorkoutSession: Identifiable, Codable, Sendable {
    let id: UUID
    let date: Date
    let week: Int
    let day: WorkoutDay
    let mesocycleId: String
    var exerciseLogs: [ExerciseLog]
    var isCompleted: Bool
    var durationSeconds: Int
    var prsSet: [String] // Exercise names where PR was set

    init(id: UUID = UUID(), date: Date = .now, week: Int, day: WorkoutDay, mesocycleId: String, exerciseLogs: [ExerciseLog] = [], isCompleted: Bool = false, durationSeconds: Int = 0, prsSet: [String] = []) {
        self.id = id
        self.date = date
        self.week = week
        self.day = day
        self.mesocycleId = mesocycleId
        self.exerciseLogs = exerciseLogs
        self.isCompleted = isCompleted
        self.durationSeconds = durationSeconds
        self.prsSet = prsSet
    }
    
    // Computed properties for calendar view
    var workoutName: String {
        "Day \(day.rawValue.prefix(1).uppercased())"
    }
    
    var exerciseCount: Int {
        exerciseLogs.count
    }
    
    var prCount: Int {
        prsSet.count
    }
    
    var totalTonnage: Double {
        exerciseLogs.reduce(0) { total, log in
            total + log.sets.filter(\.isCompleted).reduce(0) { $0 + ($1.weight * Double($1.reps)) }
        }
    }
    
    var exercises: [CompletedExercise] {
        exerciseLogs.map { log in
            let completedSets = log.sets.filter(\.isCompleted)
            let maxWeight = completedSets.map(\.weight).max() ?? 0
            let avgReps = completedSets.isEmpty ? 0 : completedSets.map(\.reps).reduce(0, +) / completedSets.count
            return CompletedExercise(
                name: log.exerciseName,
                sets: completedSets.count,
                reps: avgReps,
                weight: maxWeight,
                isPR: prsSet.contains(log.exerciseName)
            )
        }
    }
}

nonisolated struct CompletedExercise: Sendable {
    let name: String
    let sets: Int
    let reps: Int
    let weight: Double
    let isPR: Bool
}

nonisolated struct PersonalRecord: Identifiable, Codable, Sendable {
    let id: UUID
    let exerciseName: String
    let weight: Double
    let date: Date

    init(id: UUID = UUID(), exerciseName: String, weight: Double, date: Date = .now) {
        self.id = id
        self.exerciseName = exerciseName
        self.weight = weight
        self.date = date
    }
}

nonisolated struct BodyMeasurement: Codable, Sendable {
    var glutes: Double
    var waist: Double
    var thighs: Double
    var date: Date

    init(glutes: Double = 0, waist: Double = 0, thighs: Double = 0, date: Date = .now) {
        self.glutes = glutes
        self.waist = waist
        self.thighs = thighs
        self.date = date
    }
}
