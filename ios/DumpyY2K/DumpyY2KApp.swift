import SwiftUI

@main
struct DumpyY2KApp: App {
    init() {
        configureTabBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
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
        for itemAppearance in [appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance] {
            itemAppearance.normal.iconColor = pink
            itemAppearance.normal.titleTextAttributes = normalAttributes
            itemAppearance.selected.iconColor = turquoise
            itemAppearance.selected.titleTextAttributes = selectedAttributes
        }

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = pink
        UITabBar.appearance().tintColor = turquoise
    }
}
