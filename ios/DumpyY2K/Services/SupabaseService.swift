import Foundation
import Supabase

@MainActor
class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    private let client: SupabaseClient
    
    private init() {
        // TODO: Replace with your Supabase credentials
        client = SupabaseClient(
            supabaseURL: URL(string: "YOUR_SUPABASE_URL")!,
            supabaseKey: "YOUR_SUPABASE_ANON_KEY"
        )
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
