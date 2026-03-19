import Foundation
import TelemetryDeck
import AppsFlyerLib
import AppTrackingTransparency
import AdSupport

@MainActor
class AnalyticsService: NSObject {
    static let shared = AnalyticsService()
    
    // MARK: - Configuration
    // TelemetryDeck App ID - get from https://dashboard.telemetrydeck.com
    private let telemetryDeckAppID = "A772EA61-6E34-4881-883F-D5982F651532"
    
    // AppsFlyer - get from https://hq.appsflyer.com
    private let appsFlyerDevKey = "BVcP3QEwr7xhitYs4teU8W"
    private let appsFlyerAppID = "6760607330"
    
    private override init() {
        super.init()
    }
    
    // MARK: - Initialization
    
    func initialize() {
        setupTelemetryDeck()
        setupAppsFlyer()
    }
    
    private func setupTelemetryDeck() {
        let config = TelemetryDeck.Config(appID: telemetryDeckAppID)
        TelemetryDeck.initialize(config: config)
    }
    
    private func setupAppsFlyer() {
        AppsFlyerLib.shared().appsFlyerDevKey = appsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = appsFlyerAppID
        AppsFlyerLib.shared().delegate = self
        
        // For debugging - remove in production
        #if DEBUG
        AppsFlyerLib.shared().isDebug = true
        #endif
    }
    
    func startAppsFlyer() {
        AppsFlyerLib.shared().start()
    }
    
    /// Request ATT permission and start AppsFlyer with IDFA if granted
    func requestTrackingAndStartAppsFlyer() {
        // ATT prompt requires a slight delay after app becomes active
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // User granted permission - AppsFlyer will use IDFA for attribution
                    print("ATT: Authorized - IDFA available for attribution")
                case .denied:
                    print("ATT: Denied - Limited attribution available")
                case .notDetermined:
                    print("ATT: Not determined")
                case .restricted:
                    print("ATT: Restricted")
                @unknown default:
                    print("ATT: Unknown status")
                }
                
                // Start AppsFlyer regardless - it works with or without IDFA
                // but attribution accuracy is better with IDFA
                DispatchQueue.main.async {
                    AppsFlyerLib.shared().start()
                }
            }
        }
    }
    
    // MARK: - Event Tracking
    
    func trackAppLaunched() {
        TelemetryDeck.signal("app_launched")
    }
    
    func trackWorkoutStarted(day: String, week: Int, mesocycle: String) {
        TelemetryDeck.signal("workout_started", parameters: [
            "day": day,
            "week": String(week),
            "mesocycle": mesocycle
        ])
        
        AppsFlyerLib.shared().logEvent("workout_started", withValues: [
            "day": day,
            "week": week,
            "mesocycle": mesocycle
        ])
    }
    
    func trackWorkoutCompleted(day: String, week: Int, durationMinutes: Int, exerciseCount: Int, prCount: Int) {
        TelemetryDeck.signal("workout_completed", parameters: [
            "day": day,
            "week": String(week),
            "duration_minutes": String(durationMinutes),
            "exercise_count": String(exerciseCount),
            "pr_count": String(prCount)
        ])
        
        AppsFlyerLib.shared().logEvent("af_tutorial_completion", withValues: [
            "day": day,
            "week": week,
            "duration_minutes": durationMinutes,
            "exercise_count": exerciseCount,
            "pr_count": prCount
        ])
    }
    
    func trackSetCompleted(exercise: String, setNumber: Int, weight: Double, reps: Int) {
        TelemetryDeck.signal("set_completed", parameters: [
            "exercise": exercise,
            "set_number": String(setNumber),
            "weight": String(Int(weight)),
            "reps": String(reps)
        ])
    }
    
    func trackPersonalRecord(exercise: String, weight: Double) {
        TelemetryDeck.signal("personal_record", parameters: [
            "exercise": exercise,
            "weight": String(Int(weight))
        ])
        
        AppsFlyerLib.shared().logEvent("personal_record", withValues: [
            "exercise": exercise,
            "weight": weight
        ])
    }
    
    func trackExerciseSwapped(from: String, to: String) {
        TelemetryDeck.signal("exercise_swapped", parameters: [
            "from": from,
            "to": to
        ])
    }
    
    func trackPhoneVerified() {
        TelemetryDeck.signal("phone_verified")
        AppsFlyerLib.shared().logEvent("af_complete_registration", withValues: nil)
    }
    
    func trackClubApplicationSubmitted() {
        TelemetryDeck.signal("club_application_submitted")
        AppsFlyerLib.shared().logEvent("club_application_submitted", withValues: nil)
    }
    
    func trackScreenView(_ screenName: String) {
        TelemetryDeck.signal("screen_view", parameters: ["screen": screenName])
    }
}

// MARK: - AppsFlyer Delegate

extension AnalyticsService: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        print("AppsFlyer conversion data: \(conversionInfo)")
    }
    
    func onConversionDataFail(_ error: any Error) {
        print("AppsFlyer conversion data error: \(error)")
    }
}
