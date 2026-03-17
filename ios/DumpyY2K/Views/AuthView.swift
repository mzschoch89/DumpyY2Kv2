import SwiftUI

struct AuthView: View {
    @State private var phoneNumber = ""
    @State private var otpCode = ""
    @State private var isLoading = false
    @State private var showOTPField = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var isPulsing = false
    
    var onAuthenticated: () -> Void
    
    var body: some View {
        ZStack {
            Y2KBackgroundGradient()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo & Header
                VStack(spacing: 16) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 155, height: 155)
                        .scaleEffect(isPulsing ? 1.15 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
                        .onAppear { isPulsing = true }
                    
                    HStack(spacing: 0) {
                        Text("DUMPY ")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(Y2K.hotPink)
                        Text("Y2K")
                            .font(.system(size: 42, weight: .bold, design: .serif))
                            .italic()
                            .foregroundStyle(Y2K.turquoise)
                            .rotationEffect(.degrees(-3))
                    }
                }
                .padding(.bottom, 50)
                
                // Auth Card
                VStack(spacing: 24) {
                    if !showOTPField {
                        // Phone Number Entry
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PHONE NUMBER")
                                .font(.system(.caption, design: .rounded, weight: .black))
                                .foregroundStyle(Y2K.hotPink)
                                .tracking(1)
                            
                            HStack(spacing: 12) {
                                Text("🇺🇸")
                                    .font(.title2)
                                
                                TextField("(555) 123-4567", text: $phoneNumber)
                                    .font(.system(.title3, design: .rounded, weight: .semibold))
                                    .keyboardType(.phonePad)
                                    .foregroundStyle(Y2K.deepPurple)
                                    .onChange(of: phoneNumber) { _, newValue in
                                        phoneNumber = formatPhoneDisplay(newValue)
                                    }
                            }
                            .padding(16)
                            .background(.white, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(Y2K.lavender, lineWidth: 2)
                            )
                            
                            // SMS Opt-in Disclaimer
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "message.fill")
                                    .font(.caption2)
                                    .foregroundStyle(Y2K.turquoise)
                                
                                Text("By entering your number, you agree to receive a one-time verification code via SMS. Message & data rates may apply.")
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundStyle(Y2K.deepPurple.opacity(0.6))
                                    .lineSpacing(2)
                            }
                            .padding(.top, 4)
                        }
                        
                        Button {
                            sendOTP()
                        } label: {
                            HStack(spacing: 8) {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("SEND CODE")
                                        .font(.system(.headline, design: .rounded, weight: .black))
                                    Image(systemName: "arrow.right")
                                        .font(.headline)
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [Y2K.hotPink, Y2K.bubblegumPink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 16)
                            )
                            .shadow(color: Y2K.hotPink.opacity(0.4), radius: 12, y: 6)
                        }
                        .disabled(phoneNumber.isEmpty || isLoading)
                        .opacity(phoneNumber.isEmpty ? 0.6 : 1)
                        
                    } else {
                        // OTP Entry
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("ENTER CODE")
                                    .font(.system(.caption, design: .rounded, weight: .black))
                                    .foregroundStyle(Y2K.hotPink)
                                    .tracking(1)
                                
                                Spacer()
                                
                                Button {
                                    withAnimation { showOTPField = false }
                                } label: {
                                    Text("Change number")
                                        .font(.system(.caption, design: .rounded, weight: .medium))
                                        .foregroundStyle(Y2K.turquoise)
                                }
                            }
                            
                            Text("Sent to \(formatPhoneDisplay(phoneNumber))")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(Y2K.deepPurple.opacity(0.6))
                            
                            TextField("000000", text: $otpCode)
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Y2K.deepPurple)
                                .padding(16)
                                .background(.white, in: RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(Y2K.turquoise, lineWidth: 2)
                                )
                        }
                        
                        Button {
                            verifyOTP()
                        } label: {
                            HStack(spacing: 8) {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("LET'S GO!")
                                        .font(.system(.headline, design: .rounded, weight: .black))
                                    Text("🍑")
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [Y2K.turquoise, Y2K.teal],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 16)
                            )
                            .shadow(color: Y2K.turquoise.opacity(0.4), radius: 12, y: 6)
                        }
                        .disabled(otpCode.count < 6 || isLoading)
                        .opacity(otpCode.count < 6 ? 0.6 : 1)
                        
                        Button {
                            sendOTP()
                        } label: {
                            Text("Resend code")
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundStyle(Y2K.hotPink)
                        }
                        .disabled(isLoading)
                    }
                }
                .padding(28)
                .background {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.white.opacity(0.95))
                        .shadow(color: Y2K.deepPurple.opacity(0.1), radius: 20, y: 10)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Footer
                HStack(spacing: 4) {
                    Text("By continuing, you agree to our")
                        .foregroundStyle(Y2K.deepPurple.opacity(0.5))
                    Link("Terms", destination: URL(string: "https://www.dumpyy2k.com/terms.html")!)
                        .foregroundStyle(Y2K.turquoise)
                    Text("&")
                        .foregroundStyle(Y2K.deepPurple.opacity(0.5))
                    Link("Privacy Policy", destination: URL(string: "https://www.dumpyy2k.com/privacy.html")!)
                        .foregroundStyle(Y2K.turquoise)
                }
                .font(.system(.caption2, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.bottom, 30)
            }
        }
        .alert("Oops!", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // Demo phone number for App Store review bypass
    private let demoPhoneNumber = "8881234567"
    private let demoOTPCode = "123456"
    
    private func sendOTP() {
        let digits = phoneNumber.filter { $0.isNumber }
        
        // App Store review bypass
        if digits == demoPhoneNumber || digits == "1\(demoPhoneNumber)" {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showOTPField = true
            }
            return
        }
        
        isLoading = true
        Task {
            do {
                try await SupabaseService.shared.sendOTP(phone: formatPhoneNumber(phoneNumber))
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showOTPField = true
                }
            } catch {
                errorMessage = "Couldn't send code. Check your number and try again."
                showError = true
            }
            isLoading = false
        }
    }
    
    private func verifyOTP() {
        let digits = phoneNumber.filter { $0.isNumber }
        
        // App Store review bypass
        if (digits == demoPhoneNumber || digits == "1\(demoPhoneNumber)") && otpCode == demoOTPCode {
            onAuthenticated()
            return
        }
        
        isLoading = true
        Task {
            do {
                try await SupabaseService.shared.verifyOTP(phone: formatPhoneNumber(phoneNumber), code: otpCode)
                onAuthenticated()
            } catch {
                errorMessage = "Invalid code. Please try again."
                showError = true
            }
            isLoading = false
        }
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        let digits = number.filter { $0.isNumber }
        if digits.hasPrefix("1") {
            return "+\(digits)"
        }
        return "+1\(digits)"
    }
    
    private func formatPhoneDisplay(_ number: String) -> String {
        let digits = number.filter { $0.isNumber }
        
        // Handle up to 10 digits (US phone number)
        let limited = String(digits.prefix(10))
        
        switch limited.count {
        case 0:
            return ""
        case 1...3:
            return "(\(limited)"
        case 4...6:
            let areaCode = limited.prefix(3)
            let middle = limited.dropFirst(3)
            return "(\(areaCode)) \(middle)"
        case 7...10:
            let areaCode = limited.prefix(3)
            let middle = limited.dropFirst(3).prefix(3)
            let last = limited.dropFirst(6)
            return "(\(areaCode)) \(middle)-\(last)"
        default:
            return limited
        }
    }
}

#Preview {
    AuthView { }
}
