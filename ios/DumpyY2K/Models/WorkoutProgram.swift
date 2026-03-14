import Foundation

nonisolated enum ExerciseCategory: String, CaseIterable, Codable, Sendable, Identifiable {
    case squat
    case hinge
    case bridge
    case abduction

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .squat: "Squat"
        case .hinge: "Hinge"
        case .bridge: "Bridge"
        case .abduction: "Abduction"
        }
    }

    var icon: String {
        switch self {
        case .squat: "figure.strengthtraining.traditional"
        case .hinge: "figure.highintensity.intervaltraining"
        case .bridge: "figure.core.training"
        case .abduction: "figure.cooldown"
        }
    }

    var customIconActive: String {
        switch self {
        case .squat: "squat-white"
        case .hinge: "hinge-white"
        case .bridge: "bridge-white"
        case .abduction: "abduction-white"
        }
    }

    var customIconInactive: String {
        switch self {
        case .squat: "squat-turquoise"
        case .hinge: "hinge-turquoise"
        case .bridge: "bridge-turquoise"
        case .abduction: "abduction-turquoise"
        }
    }

    var restSeconds: Int {
        switch self {
        case .squat, .hinge: 90
        case .bridge, .abduction: 60
        }
    }
}

nonisolated enum WorkoutDay: String, Codable, Sendable {
    case dayA = "A"
    case dayB = "B"

    var label: String {
        switch self {
        case .dayA: "Day A"
        case .dayB: "Day B"
        }
    }
}

nonisolated enum EffortLevel: String, Codable, Sendable {
    case casual
    case almostToFailure = "almost_to_failure"
    case toFailure = "to_failure"

    var displayName: String {
        switch self {
        case .casual: "Casual"
        case .almostToFailure: "Almost to Failure"
        case .toFailure: "To Failure"
        }
    }

    var description: String {
        switch self {
        case .casual: "You could do 4-5 more reps. Controlled and comfortable."
        case .almostToFailure: "You could squeeze out 1-2 more ugly reps. This is where growth happens."
        case .toFailure: "You literally cannot do another rep with good form."
        }
    }

    var emoji: String {
        switch self {
        case .casual: "😌"
        case .almostToFailure: "🔥"
        case .toFailure: "💀"
        }
    }

    var color: String {
        switch self {
        case .casual: "green"
        case .almostToFailure: "orange"
        case .toFailure: "red"
        }
    }
}

nonisolated struct Exercise: Identifiable, Codable, Sendable, Hashable {
    let id: String
    let name: String
    let cue: String
    let category: ExerciseCategory
    let isBackup: Bool

    var iconWhite: String {
        "\(id)-white"
    }

    var iconTurquoise: String {
        "\(id)-turquoise"
    }

    nonisolated static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

nonisolated struct Mesocycle: Identifiable, Codable, Sendable {
    let id: String
    let name: String
    let weeks: [Int]
    let goal: String
    let effort: String
    let howToProgress: String
    let repRanges: [ExerciseCategory: String]
    let totalWorkingSets: Int

    func setsForCategory(_ category: ExerciseCategory) -> Int {
        switch id {
        case "meso_1": return 3
        case "meso_2":
            switch category {
            case .squat, .hinge: return 3
            case .bridge, .abduction: return 4
            }
        case "meso_3": return 4
        case "deload": return 2
        default: return 3
        }
    }

    var effortLevel: EffortLevel {
        switch id {
        case "meso_1", "deload": return .casual
        case "meso_2": return .almostToFailure
        case "meso_3": return .toFailure
        default: return .casual
        }
    }
}

struct WorkoutProgramData {
    static let exercises: [ExerciseCategory: [WorkoutDay: (primary: Exercise, backup: Exercise)]] = [
        .squat: [
            .dayA: (
                primary: Exercise(id: "smith_deficit_lunge", name: "Smith Deficit Reverse Lunge", cue: "Stand on a small platform, step back and sink deep. Push through your front heel to stand back up. You should feel a deep stretch in your glute at the bottom.", category: .squat, isBackup: false),
                backup: Exercise(id: "bulgarian_split_squat", name: "Dumbbell Bulgarian Split Squat", cue: "Back foot on bench, lean your torso slightly forward, sink down and drive up through front heel", category: .squat, isBackup: true)
            ),
            .dayB: (
                primary: Exercise(id: "leg_press", name: "Leg Press (High & Wide)", cue: "Feet high on the platform and wider than shoulder width. Push through your heels. Go as deep as you can without your lower back lifting off the pad.", category: .squat, isBackup: false),
                backup: Exercise(id: "goblet_squat", name: "Goblet Squat", cue: "Hold a dumbbell at your chest, wide stance, sit as deep as you can, drive up through heels", category: .squat, isBackup: true)
            )
        ],
        .hinge: [
            .dayA: (
                primary: Exercise(id: "rdl", name: "Romanian Deadlift (RDL)", cue: "Push your hips back like you're closing a car door with your butt. Feel the stretch in your hamstrings, then stand tall and squeeze glutes", category: .hinge, isBackup: false),
                backup: Exercise(id: "db_rdl", name: "Dumbbell RDL", cue: "Same movement, dumbbells hang in front of thighs", category: .hinge, isBackup: true)
            ),
            .dayB: (
                primary: Exercise(id: "back_extension", name: "45° Back Extension (Glute Focus)", cue: "Toes turned out slightly, round over the pad at the bottom, then squeeze your glutes to come up. Think about your glutes doing the work, not your lower back.", category: .hinge, isBackup: false),
                backup: Exercise(id: "cable_pull_through", name: "Cable Pull-Through", cue: "Face away from cable, rope between legs, push hips back then snap them forward", category: .hinge, isBackup: true)
            )
        ],
        .bridge: [
            .dayA: (
                primary: Exercise(id: "machine_hip_thrust", name: "Machine Hip Thrust", cue: "Squeeze your glutes hard at the top and hold for a beat before lowering", category: .bridge, isBackup: false),
                backup: Exercise(id: "banded_hip_thrust", name: "Banded Hip Thrust Off Bench", cue: "Band above knees, back on bench edge, drive hips up and squeeze", category: .bridge, isBackup: true)
            ),
            .dayB: (
                primary: Exercise(id: "barbell_hip_thrust", name: "Barbell Hip Thrust", cue: "Back on bench, drive through your heels, squeeze glutes hard at the top", category: .bridge, isBackup: false),
                backup: Exercise(id: "single_leg_bridge", name: "Single-Leg Glute Bridge", cue: "One foot on the ground, other leg straight up. Squeeze at top.", category: .bridge, isBackup: true)
            )
        ],
        .abduction: [
            .dayA: (
                primary: Exercise(id: "seated_abduction", name: "Seated Abduction Machine", cue: "Lean your torso forward slightly — this shifts the work into your upper glutes. Push knees apart and squeeze.", category: .abduction, isBackup: false),
                backup: Exercise(id: "banded_abduction", name: "Banded Seated Abduction", cue: "Band above knees, sit on edge of bench, lean forward, push knees apart", category: .abduction, isBackup: true)
            ),
            .dayB: (
                primary: Exercise(id: "reclined_abduction", name: "Reclined Abduction Machine", cue: "Lean the seat back if your machine allows it. The reclined angle hits a slightly different part of your glutes.", category: .abduction, isBackup: false),
                backup: Exercise(id: "clamshells", name: "Side-Lying Clamshells / Fire Hydrants", cue: "Band above knees, high reps, keep constant tension — don't rest at the bottom", category: .abduction, isBackup: true)
            )
        ]
    ]

    static let mesocycles: [Mesocycle] = [
        Mesocycle(
            id: "meso_1", name: "BUILD THAT BASE", weeks: [1, 2],
            goal: "Find your working weights, get comfortable with every exercise, start building strength",
            effort: "casual",
            howToProgress: "When you can hit the top number of reps on all 3 sets, go up in weight next time.",
            repRanges: [.squat: "10-12 per leg", .hinge: "8-10", .bridge: "10-12", .abduction: "15-20"],
            totalWorkingSets: 12
        ),
        Mesocycle(
            id: "meso_2", name: "Turn It Up", weeks: [3, 4, 5, 6, 7],
            goal: "More volume, heavier weights, start really challenging yourself",
            effort: "almost_to_failure",
            howToProgress: "Increase weight 5-10% from weeks 1-2. Keep pushing for more reps or more weight every session.",
            repRanges: [.squat: "8-10 per leg", .hinge: "8-10", .bridge: "10-12", .abduction: "15-20"],
            totalWorkingSets: 14
        ),
        Mesocycle(
            id: "meso_3", name: "Go All Out", weeks: [8, 9, 10, 11, 12],
            goal: "Heaviest weights of the program, push for personal records on every exercise",
            effort: "to_failure on last set",
            howToProgress: "Push for new personal bests. If you hit the top of the rep range on all 4 sets, add weight next session.",
            repRanges: [.squat: "8-10 per leg", .hinge: "8-10", .bridge: "10-12", .abduction: "12-20"],
            totalWorkingSets: 16
        ),
        Mesocycle(
            id: "deload", name: "Recovery Week", weeks: [13],
            goal: "Let your body catch up and absorb all the work. This is where growth actually happens.",
            effort: "casual",
            howToProgress: "No progression. Use lighter weight than week 1. It should feel easy.",
            repRanges: [.squat: "10-12 per leg", .hinge: "8-10", .bridge: "10-12", .abduction: "15-20"],
            totalWorkingSets: 8
        )
    ]

    static func exercisesForDay(_ day: WorkoutDay) -> [Exercise] {
        ExerciseCategory.allCases.compactMap { category in
            exercises[category]?[day]?.primary
        }
    }

    static func currentMesocycle(forWeek week: Int) -> Mesocycle? {
        mesocycles.first { $0.weeks.contains(week) }
    }
}
