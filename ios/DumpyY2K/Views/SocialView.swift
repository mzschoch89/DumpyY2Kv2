import SwiftUI

struct SocialView: View {
    let viewModel: WorkoutViewModel
    @AppStorage("hasAppliedToJoin") private var hasApplied = false
    @AppStorage("userEmail") private var userEmail = ""
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showEmailRequired = false
    @State private var navigateToSettings = false
    
    var body: some View {
        NavigationStack {
            mainContent
                .navigationDestination(isPresented: $navigateToSettings) {
                    SettingsView(viewModel: viewModel)
                }
        }
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 40)
                comingSoonCard
                featuresPreview
                Spacer(minLength: 40)
            }
            .padding(.horizontal)
        }
        .background { Y2KBackgroundGradient() }
    }

    private var comingSoonCard: some View {
        ZStack {
            Y2KCardGradient(style: 0)
                .clipShape(.rect(cornerRadius: 28))

            VStack(spacing: 22) {
                Text("🍑")
                    .font(.system(size: 60))

                VStack(spacing: 8) {
                    Text("GLUTE CLUB")
                        .font(.system(.caption, design: .rounded, weight: .black))
                        .foregroundStyle(.white.opacity(0.9))
                        .tracking(3)

                    HStack(spacing: 0) {
                        Text("COMING ")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Soon")
                            .font(.system(size: 34, weight: .bold, design: .serif))
                            .italic()
                            .foregroundStyle(.white)
                    }
                    .shadow(color: Y2K.hotPink.opacity(0.3), radius: 4, y: 2)
                }

                Text("Connect with your glute gang,\nshare PRs, and hype each other up.")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                VStack(spacing: 8) {
                    Button {
                        if userEmail.isEmpty {
                            showEmailRequired = true
                        } else {
                            submitApplication()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            if isSubmitting {
                                ProgressView()
                                    .tint(Y2K.deepPurple)
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: hasApplied ? "checkmark.circle.fill" : "cursorarrow.click.2")
                                    .font(.caption)
                            }
                            Text(hasApplied ? "APPLIED" : "APPLY TO JOIN")
                                .font(.system(.caption, design: .rounded, weight: .black))
                        }
                        .foregroundStyle(Y2K.deepPurple)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(.white.opacity(0.85), in: Capsule())
                    }
                    .disabled(hasApplied || isSubmitting)
                    
                    Text("This will only share your email.\nYou can later choose a name to join the community.")
                        .font(.system(.caption, design: .rounded, weight: .light))
                        .foregroundStyle(Y2K.lavender)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .alert("Error", isPresented: $showError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
                .sheet(isPresented: $showEmailRequired) {
                    EmailRequiredSheet(navigateToSettings: $navigateToSettings, showSheet: $showEmailRequired)
                        .presentationDetents([.height(320)])
                }
            }
            .padding(32)

            SparkleDecoration(size: 20, color: .white.opacity(0.8))
                .offset(x: -130, y: -130)
            SparkleDecoration(size: 14, color: Y2K.brightYellow)
                .offset(x: 140, y: -110)
            SparkleDecoration(size: 12, color: .white.opacity(0.6))
                .offset(x: -120, y: 120)
        }
        .frame(height: 380)
    }
    
    private func submitApplication() {
        guard !userEmail.isEmpty else {
            // For now, just mark as applied locally
            // In production, you'd prompt for email or get from auth
            hasApplied = true
            return
        }
        
        isSubmitting = true
        Task {
            do {
                try await SupabaseService.shared.submitClubApplication(email: userEmail)
                hasApplied = true
            } catch {
                errorMessage = "Failed to submit application. Please try again."
                showError = true
            }
            isSubmitting = false
        }
    }

    private var featuresPreview: some View {
        VStack(spacing: 14) {
            UpcomingFeatureRow(icon: "trophy.fill", title: "WEEKLY LEADERS", detail: "Compete with friends on the leaderboard", borderColor: Y2K.teal)
            UpcomingFeatureRow(icon: "bubble.left.fill", title: "GLUTE CLUB FEED", detail: "Share workouts and PRs with your community", borderColor: Y2K.deepPurple)
            UpcomingFeatureRow(icon: "camera.fill", title: "PROGRESS PICS", detail: "Track your visual transformation journey", borderColor: Y2K.hotPink)
        }
    }
}

struct UpcomingFeatureRow: View {
    let icon: String
    let title: String
    let detail: String
    var borderColor: Color = Y2K.teal

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(borderColor)
                .frame(width: 46, height: 46)
                .background(borderColor.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .black))
                    .foregroundStyle(Y2K.deepGreen.opacity(0.5))
                Text(detail)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Y2K.deepGreen.opacity(0.4))
            }

            Spacer()
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.85))
        }
        .y2kSolidBorder(color: borderColor.opacity(0.4), cornerRadius: 20, lineWidth: 2)
    }
}

// MARK: - Email Required Sheet

struct EmailRequiredSheet: View {
    @Binding var navigateToSettings: Bool
    @Binding var showSheet: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Cute emoji header
            Text("📧")
                .font(.system(size: 60))
            
            VStack(spacing: 8) {
                Text("One more thing!")
                    .font(.system(.title2, design: .rounded, weight: .black))
                    .foregroundStyle(Y2K.hotPink)
                
                Text("Add your email to your settings\nbefore applying to the Glute Club!")
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundStyle(Y2K.deepPurple.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            VStack(spacing: 12) {
                Button {
                    showSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        navigateToSettings = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "gearshape.fill")
                        Text("GO TO SETTINGS")
                            .font(.system(.subheadline, design: .rounded, weight: .black))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [Y2K.hotPink, Y2K.bubblegumPink], startPoint: .leading, endPoint: .trailing),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                }
                
                Button {
                    showSheet = false
                } label: {
                    Text("Maybe later")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(Y2K.turquoise)
                }
            }
        }
        .padding(32)
        .background { Y2KBackgroundGradient() }
    }
}
