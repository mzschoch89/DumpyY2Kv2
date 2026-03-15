import SwiftUI

@main
struct DumpyY2KApp: App {
    init() {
        // Force light keyboard appearance
        UITextField.appearance().keyboardAppearance = .light
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
