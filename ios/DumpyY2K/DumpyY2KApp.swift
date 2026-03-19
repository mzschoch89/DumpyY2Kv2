import SwiftUI

@main
struct DumpyY2KApp: App {
    init() {
        AnalyticsService.shared.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .onAppear {
                    AnalyticsService.shared.trackAppLaunched()
                    // AppsFlyer is started AFTER ATT prompt in ContentView
                    // This ensures we request permission BEFORE collecting tracking data
                }
        }
    }
}
