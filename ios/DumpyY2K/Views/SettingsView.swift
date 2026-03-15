import SwiftUI

struct SettingsView: View {
    let viewModel: WorkoutViewModel
    @State private var showDeleteConfirmation = false
    @State private var showLogoutConfirmation = false
    @State private var showEmailSheet = false
    @AppStorage("userEmail") private var userEmail = ""
    @AppStorage("userPhone") private var userPhone = "(888) 123-4567"
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    
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
                deleteAccount()
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
    }
    
    private func deleteAccount() {
        Task {
            // Delete from Supabase
            try? await SupabaseService.shared.deleteAccount()
            
            // Clear local data
            userEmail = ""
            userPhone = ""
            UserDefaults.standard.removeObject(forKey: "hasAppliedToJoin")
            
            // Clear workout data from UserDefaults
            UserDefaults.standard.removeObject(forKey: "completedSessions")
            UserDefaults.standard.removeObject(forKey: "personalRecords")
            UserDefaults.standard.removeObject(forKey: "bodyMeasurements")
            UserDefaults.standard.removeObject(forKey: "currentWeek")
            
            // Clear in-memory workout data
            viewModel.completedSessions = []
            viewModel.personalRecords = []
            viewModel.bodyMeasurements = []
            viewModel.currentWeek = 1
            
            // Log out
            isAuthenticated = false
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
            
            // Phone Number Row
            HStack(spacing: 12) {
                Image(systemName: "phone.fill")
                    .font(.subheadline)
                    .foregroundStyle(Y2K.hotPink)
                    .frame(width: 34, height: 34)
                    .background(Y2K.hotPink.opacity(0.12), in: Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Phone Number")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(Y2K.deepGreen)
                    Text(userPhone)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Y2K.deepGreen.opacity(0.6))
                }
                
                Spacer()
            }
            
            // Email Row
            Button {
                showEmailSheet = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "envelope.fill")
                        .font(.subheadline)
                        .foregroundStyle(Y2K.bubblegumPink)
                        .frame(width: 34, height: 34)
                        .background(Y2K.bubblegumPink.opacity(0.12), in: Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(userEmail.isEmpty ? "Add Email Address" : "Email")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(Y2K.deepGreen)
                        Text(userEmail.isEmpty ? "Optional, for app updates only" : userEmail)
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
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.9))
                .shadow(color: Y2K.hotPink.opacity(0.08), radius: 8, y: 4)
        }
        .y2kDashedBorder(color: Y2K.hotPink, cornerRadius: 22)
        .sheet(isPresented: $showEmailSheet) {
            EmailEditSheet(email: $userEmail)
                .presentationDetents([.medium])
        }
    }
    
    private var subscriptionSection: some View {
        ZStack(alignment: .topTrailing) {
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
                    // Coming soon
                } label: {
                    Text("UPGRADE TO PRO")
                        .font(.system(.subheadline, design: .rounded, weight: .black))
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing),
                            in: Capsule()
                        )
                }
                .disabled(true)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 22)
                    .fill(.white.opacity(0.9))
                    .shadow(color: Y2K.limeGreen.opacity(0.08), radius: 8, y: 4)
            }
            .y2kSolidBorder(color: Y2K.limeGreen, cornerRadius: 22)
            
            // Coming Soon Sticker
            Text("COMING SOON ✨")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    LinearGradient(colors: [Y2K.hotPink, Y2K.bubblegumPink], startPoint: .leading, endPoint: .trailing),
                    in: Capsule()
                )
                .rotationEffect(.degrees(12))
                .offset(x: -8, y: -8)
        }
    }
    
    private var legalSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("LEGAL")
                .font(.system(.caption, design: .rounded, weight: .black))
                .foregroundStyle(Y2K.lavender)
                .tracking(1.5)
            
            Link(destination: URL(string: "https://dumpyy2k.com/privacy")!) {
                HStack(spacing: 12) {
                    Image(systemName: "lock.shield.fill")
                        .font(.subheadline)
                        .foregroundStyle(Y2K.lavender)
                        .frame(width: 34, height: 34)
                        .background(Y2K.lavender.opacity(0.12), in: Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Privacy Policy")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(Y2K.deepGreen)
                        Text("How we handle your data")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(Y2K.deepGreen.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(Y2K.deepGreen.opacity(0.3))
                }
            }
            
            Link(destination: URL(string: "https://dumpyy2k.com/terms")!) {
                HStack(spacing: 12) {
                    Image(systemName: "doc.text.fill")
                        .font(.subheadline)
                        .foregroundStyle(Y2K.deepPurple)
                        .frame(width: 34, height: 34)
                        .background(Y2K.deepPurple.opacity(0.12), in: Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Terms & Conditions")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(Y2K.deepGreen)
                        Text("Usage terms and rules")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(Y2K.deepGreen.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(Y2K.deepGreen.opacity(0.3))
                }
            }
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
            
            // Log Out Button
            Button {
                showLogoutConfirmation = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                        .frame(width: 34, height: 34)
                        .background(.orange.opacity(0.12), in: Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Log Out")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(.orange)
                        Text("Sign out of your account")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.orange.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.orange.opacity(0.4))
                }
            }
            
            // Delete Account Button
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
        .alert("Log Out", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                isAuthenticated = false
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
}

// MARK: - Email Edit Sheet

struct EmailEditSheet: View {
    @Binding var email: String
    @State private var editedEmail = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("EMAIL ADDRESS")
                        .font(.system(.caption, design: .rounded, weight: .black))
                        .foregroundStyle(Y2K.hotPink)
                        .tracking(1)
                    
                    TextField("your@email.com", text: $editedEmail)
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .foregroundStyle(Y2K.deepPurple)
                        .padding(16)
                        .background(.white, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Y2K.lavender, lineWidth: 2)
                        )
                }
                
                // Privacy Notice
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .font(.caption)
                        .foregroundStyle(Y2K.turquoise)
                    
                    Text("Your email will only be used for important app updates and account recovery. We never sell or share your information.")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Y2K.deepPurple.opacity(0.6))
                        .lineSpacing(2)
                }
                .padding(16)
                .background(Y2K.turquoise.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                
                Spacer()
                
                Button {
                    email = editedEmail
                    // Save to Supabase
                    Task {
                        try? await SupabaseService.shared.updateUserEmail(email: editedEmail)
                    }
                    dismiss()
                } label: {
                    Text("SAVE")
                        .font(.system(.headline, design: .rounded, weight: .black))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [Y2K.hotPink, Y2K.bubblegumPink], startPoint: .leading, endPoint: .trailing),
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                }
            }
            .padding(24)
            .background { Y2KBackgroundGradient() }
            .navigationTitle("Email")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Y2K.hotPink)
                }
            }
        }
        .onAppear {
            editedEmail = email
        }
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
