import SwiftUI

struct ContentView: View {
    @State private var viewModel = WorkoutViewModel()
    @State private var selectedTab: AppTab = .gym
    @State private var showWorkout: Bool = false

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color(red: 0.98, green: 0.95, blue: 0.96))
        let turquoise = UIColor(Y2K.turquoise)
        let pink = UIColor(Y2K.hotPink)

        // Configure all layout appearances (stacked, inline, compactInline)
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: pink,
            .font: UIFont.systemFont(ofSize: 10, weight: .bold)
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: turquoise,
            .font: UIFont.systemFont(ofSize: 10, weight: .heavy)
        ]

        // Stacked (default iPhone portrait)
        appearance.stackedLayoutAppearance.normal.iconColor = pink
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.selected.iconColor = turquoise
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes

        // Inline (iPad, landscape)
        appearance.inlineLayoutAppearance.normal.iconColor = pink
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.inlineLayoutAppearance.selected.iconColor = turquoise
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes

        // Compact inline
        appearance.compactInlineLayoutAppearance.normal.iconColor = pink
        appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.compactInlineLayoutAppearance.selected.iconColor = turquoise
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = pink
        UITabBar.appearance().tintColor = turquoise
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(viewModel: viewModel, showWorkout: $showWorkout)
            }
            .tabItem {
                Image(systemName: "sparkles")
                    .renderingMode(.template)
                Text("HOME")
            }
            .tag(AppTab.gym)

            NavigationStack {
                PlansView(viewModel: viewModel)
            }
            .tabItem {
                Image(systemName: "square.grid.2x2.fill")
                    .renderingMode(.template)
                Text("PLANS")
            }
            .tag(AppTab.plans)

            NavigationStack {
                ProgressTabView(viewModel: viewModel)
            }
            .tabItem {
                Image(systemName: "camera.fill")
                    .renderingMode(.template)
                Text("PROGRESS")
            }
            .tag(AppTab.gains)

            NavigationStack {
                SocialView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                    .renderingMode(.template)
                Text("SOCIAL")
            }
            .tag(AppTab.social)
        }
        .tint(Y2K.turquoise)
        .fullScreenCover(isPresented: $showWorkout) {
            ActiveWorkoutView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.load()
        }
    }
}

nonisolated enum AppTab: Hashable, Sendable {
    case gym
    case plans
    case gains
    case social
}
