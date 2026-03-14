import SwiftUI

struct SocialView: View {
    @AppStorage("hasAppliedToJoin") private var hasApplied = false
    
    var body: some View {
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
                        hasApplied = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: hasApplied ? "checkmark.circle.fill" : "cursorarrow.click.2")
                                .font(.caption)
                            Text(hasApplied ? "APPLIED" : "APPLY TO JOIN")
                                .font(.system(.caption, design: .rounded, weight: .black))
                        }
                        .foregroundStyle(Y2K.deepPurple)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(.white.opacity(0.85), in: Capsule())
                    }
                    .disabled(hasApplied)
                    
                    Text("This will only share your email.\nYou can later choose a name to join the community.")
                        .font(.system(.caption, design: .rounded, weight: .light))
                        .foregroundStyle(Y2K.lavender)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
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
