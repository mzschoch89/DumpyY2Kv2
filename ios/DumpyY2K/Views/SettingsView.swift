import SwiftUI

struct SettingsView: View {
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                accountSection
                subscriptionSection
                legalSection
                dangerZone
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background { Y2KBackgroundGradient() }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // Handle account deletion
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text("DUMPY Y2K")
                    .font(.system(.caption, design: .rounded, weight: .black))
                    .foregroundStyle(Y2K.hotPink)
                    .tracking(2)
                Text("⚙️")
            }
            Text("SETTINGS")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(Y2K.deepGreen)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("ACCOUNT")
                .font(.system(.caption, design: .rounded, weight: .black))
                .foregroundStyle(Y2K.hotPink)
                .tracking(1.5)
            
            SettingsRow(icon: "person.fill", title: "Account Details", subtitle: "Manage your profile info", color: Y2K.hotPink)
            SettingsRow(icon: "envelope.fill", title: "Email", subtitle: "user@example.com", color: Y2K.bubblegumPink)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.9))
                .shadow(color: Y2K.hotPink.opacity(0.08), radius: 8, y: 4)
        }
        .y2kDashedBorder(color: Y2K.hotPink, cornerRadius: 22)
    }
    
    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("SUBSCRIPTION")
                .font(.system(.caption, design: .rounded, weight: .black))
                .foregroundStyle(Y2K.limeGreen)
                .tracking(1.5)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("FREE PLAN")
                        .font(.system(.headline, design: .rounded, weight: .black))
                        .foregroundStyle(Y2K.deepGreen)
                    Text("Upgrade for premium features")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Y2K.deepGreen.opacity(0.6))
                }
                Spacer()
                Text("✨")
                    .font(.title)
            }
            
            Button {
                // Handle upgrade
            } label: {
                Text("UPGRADE TO PRO")
                    .font(.system(.subheadline, design: .rounded, weight: .black))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [Y2K.hotPink, Y2K.bubblegumPink], startPoint: .leading, endPoint: .trailing),
                        in: Capsule()
                    )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.9))
                .shadow(color: Y2K.limeGreen.opacity(0.08), radius: 8, y: 4)
        }
        .y2kSolidBorder(color: Y2K.limeGreen, cornerRadius: 22)
    }
    
    private var legalSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("LEGAL")
                .font(.system(.caption, design: .rounded, weight: .black))
                .foregroundStyle(Y2K.lavender)
                .tracking(1.5)
            
            SettingsRow(icon: "lock.shield.fill", title: "Privacy Policy", subtitle: "How we handle your data", color: Y2K.lavender)
            SettingsRow(icon: "doc.text.fill", title: "Terms & Conditions", subtitle: "Usage terms and rules", color: Y2K.deepPurple)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.9))
                .shadow(color: Y2K.lavender.opacity(0.08), radius: 8, y: 4)
        }
        .y2kDashedBorder(color: Y2K.lavender, cornerRadius: 22)
    }
    
    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("DANGER ZONE")
                .font(.system(.caption, design: .rounded, weight: .black))
                .foregroundStyle(.red)
                .tracking(1.5)
            
            Button {
                showDeleteConfirmation = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "trash.fill")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .frame(width: 34, height: 34)
                        .background(.red.opacity(0.12), in: Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Delete Account")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(.red)
                        Text("Permanently remove your data")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.red.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.red.opacity(0.4))
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.9))
                .shadow(color: .red.opacity(0.08), radius: 8, y: 4)
        }
        .y2kSolidBorder(color: .red.opacity(0.4), cornerRadius: 22)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var color: Color = Y2K.hotPink
    
    var body: some View {
        Button {
            // Handle tap
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(color)
                    .frame(width: 34, height: 34)
                    .background(color.opacity(0.12), in: Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(Y2K.deepGreen)
                    Text(subtitle)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Y2K.deepGreen.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Y2K.deepGreen.opacity(0.3))
            }
        }
    }
}
