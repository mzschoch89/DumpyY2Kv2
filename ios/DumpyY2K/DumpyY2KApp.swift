import SwiftUI

@main
struct DumpyY2KApp: App {
    init() {
        // Force light keyboard appearance
        UITextField.appearance().keyboardAppearance = .light
        UITextView.appearance().keyboardAppearance = .light
        
        // Force light mode for the entire app (ensures light keyboard)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
