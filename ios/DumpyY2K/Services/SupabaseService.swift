import Foundation
import Supabase

@MainActor
class SupabaseService {
    static let shared = SupabaseService()
    
    private let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://sfrmmnucqagjivjkpkvw.supabase.co")!,
            supabaseKey: "sb_publishable_e8xIjWbwpeY2DXlcqcAlug_D7IlY_nZ"
        )
    }
    
    // MARK: - Phone Auth
    
    func sendOTP(phone: String) async throws {
        try await client.auth.signInWithOTP(phone: phone)
    }
    
    func verifyOTP(phone: String, code: String) async throws {
        try await client.auth.verifyOTP(phone: phone, token: code, type: .sms)
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func deleteAccount() async throws {
        guard let userId = currentUser?.id else { return }
        
        // Delete user profile
        try await client
            .from("user_profiles")
            .delete()
            .eq("id", value: userId.uuidString)
            .execute()
        
        // Delete club applications
        try await client
            .from("club_applications")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .execute()
        
        // Sign out
        try await client.auth.signOut()
    }
    
    var currentUser: Supabase.User? {
        client.auth.currentUser
    }
    
    var isAuthenticated: Bool {
        currentUser != nil
    }
    
    // MARK: - User Profile
    
    func updateUserEmail(email: String) async throws {
        guard let userId = currentUser?.id else { return }
        
        try await client
            .from("user_profiles")
            .upsert([
                "id": userId.uuidString,
                "email": email,
                "updated_at": ISO8601DateFormatter().string(from: Date())
            ])
            .execute()
    }
    
    func getUserProfile() async throws -> UserProfile? {
        guard let userId = currentUser?.id else { return nil }
        
        let response: [UserProfile] = try await client
            .from("user_profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .limit(1)
            .execute()
            .value
        
        return response.first
    }
    
    // MARK: - Club Applications
    
    func submitClubApplication(email: String) async throws {
        let application = ClubApplication(
            email: email,
            status: "pending",
            appliedAt: Date()
        )
        
        try await client
            .from("club_applications")
            .insert(application)
            .execute()
    }
    
    func getApplicationStatus() async throws -> String? {
        let response: [ClubApplication] = try await client
            .from("club_applications")
            .select()
            .limit(1)
            .execute()
            .value
        
        return response.first?.status
    }
    
    // MARK: - Workout Sync
    
    func syncWorkoutSession(_ session: WorkoutSession) async throws {
        guard let userId = currentUser?.id else { return }
        
        let workoutRecord = WorkoutRecord(
            id: session.id,
            userId: userId,
            date: session.date,
            week: session.week,
            day: session.day.rawValue,
            mesocycleId: session.mesocycleId,
            exerciseLogs: session.exerciseLogs,
            isCompleted: session.isCompleted,
            durationSeconds: session.durationSeconds,
            prsSet: session.prsSet
        )
        
        try await client
            .from("workouts")
            .upsert(workoutRecord)
            .execute()
    }
    
    func fetchWorkoutSessions() async throws -> [WorkoutSession] {
        guard let userId = currentUser?.id else { return [] }
        
        let records: [WorkoutRecord] = try await client
            .from("workouts")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("date", ascending: false)
            .execute()
            .value
        
        return records.map { $0.toWorkoutSession() }
    }
    
    func syncPersonalRecords(_ records: [PersonalRecord]) async throws {
        guard let userId = currentUser?.id else { return }
        
        let prRecords = records.map { pr in
            PRRecord(
                id: pr.id,
                userId: userId,
                exerciseName: pr.exerciseName,
                weight: pr.weight,
                date: pr.date
            )
        }
        
        // Delete existing and insert fresh
        try await client
            .from("personal_records")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .execute()
        
        if !prRecords.isEmpty {
            try await client
                .from("personal_records")
                .insert(prRecords)
                .execute()
        }
    }
    
    func fetchPersonalRecords() async throws -> [PersonalRecord] {
        guard let userId = currentUser?.id else { return [] }
        
        let records: [PRRecord] = try await client
            .from("personal_records")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value
        
        return records.map { $0.toPersonalRecord() }
    }
    
    func syncCurrentWeek(_ week: Int) async throws {
        guard let userId = currentUser?.id else { return }
        
        try await client
            .from("user_profiles")
            .upsert([
                "id": userId.uuidString,
                "current_week": week,
                "updated_at": ISO8601DateFormatter().string(from: Date())
            ])
            .execute()
    }
    
    func fetchCurrentWeek() async throws -> Int? {
        guard let userId = currentUser?.id else { return nil }
        
        struct WeekResponse: Codable {
            let currentWeek: Int?
            
            enum CodingKeys: String, CodingKey {
                case currentWeek = "current_week"
            }
        }
        
        let response: [WeekResponse] = try await client
            .from("user_profiles")
            .select("current_week")
            .eq("id", value: userId.uuidString)
            .limit(1)
            .execute()
            .value
        
        return response.first?.currentWeek
    }
}

// MARK: - Workout Sync Models

struct WorkoutRecord: Codable {
    let id: UUID
    let userId: UUID
    let date: Date
    let week: Int
    let day: String
    let mesocycleId: String
    let exerciseLogs: [ExerciseLog]
    let isCompleted: Bool
    let durationSeconds: Int
    let prsSet: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case date
        case week
        case day
        case mesocycleId = "mesocycle_id"
        case exerciseLogs = "exercise_logs"
        case isCompleted = "is_completed"
        case durationSeconds = "duration_seconds"
        case prsSet = "prs_set"
    }
    
    func toWorkoutSession() -> WorkoutSession {
        WorkoutSession(
            id: id,
            date: date,
            week: week,
            day: WorkoutDay(rawValue: day) ?? .dayA,
            mesocycleId: mesocycleId,
            exerciseLogs: exerciseLogs,
            isCompleted: isCompleted,
            durationSeconds: durationSeconds,
            prsSet: prsSet
        )
    }
}

struct PRRecord: Codable {
    let id: UUID
    let userId: UUID
    let exerciseName: String
    let weight: Double
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case exerciseName = "exercise_name"
        case weight
        case date
    }
    
    func toPersonalRecord() -> PersonalRecord {
        PersonalRecord(
            id: id,
            exerciseName: exerciseName,
            weight: weight,
            date: date
        )
    }
}

// MARK: - Models

struct UserProfile: Codable {
    let id: String
    var email: String?
    var phone: String?
    var updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case phone
        case updatedAt = "updated_at"
    }
}

struct ClubApplication: Codable {
    var id: UUID?
    let email: String
    var displayName: String?
    let status: String
    let appliedAt: Date
    var reviewedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName = "display_name"
        case status
        case appliedAt = "applied_at"
        case reviewedAt = "reviewed_at"
    }
}
