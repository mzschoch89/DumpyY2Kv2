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
                    // Start AppsFlyer without ATT on launch
                    // ATT prompt is triggered after authentication in ContentView
                    AnalyticsService.shared.startAppsFlyer()
                }
        }
    }
}
