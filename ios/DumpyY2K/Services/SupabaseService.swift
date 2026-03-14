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
