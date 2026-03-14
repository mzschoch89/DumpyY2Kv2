import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        configureTabBarAppearance()
        return true
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color(red: 0.98, green: 0.95, blue: 0.96))

        let turquoise = UIColor(Y2K.turquoise)
        let pink = UIColor(Y2K.hotPink)

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: pink,
            .font: UIFont.systemFont(ofSize: 10, weight: .bold)
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: turquoise,
            .font: UIFont.systemFont(ofSize: 10, weight: .heavy)
        ]

        // Configure all layout appearances
        appearance.stackedLayoutAppearance.normal.iconColor = pink
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.selected.iconColor = turquoise
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes

        appearance.inlineLayoutAppearance.normal.iconColor = pink
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.inlineLayoutAppearance.selected.iconColor = turquoise
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes

        appearance.compactInlineLayoutAppearance.normal.iconColor = pink
        appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.compactInlineLayoutAppearance.selected.iconColor = turquoise
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = pink
        UITabBar.appearance().tintColor = turquoise
    }
}

@main
struct DumpyY2KApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
