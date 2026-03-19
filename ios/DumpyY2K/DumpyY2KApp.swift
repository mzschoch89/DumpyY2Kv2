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
                    // Request ATT permission, then start AppsFlyer
                    AnalyticsService.shared.requestTrackingAndStartAppsFlyer()
                }
        }
    }
}
