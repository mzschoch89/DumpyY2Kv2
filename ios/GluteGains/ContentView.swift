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

        appearance.stackedLayoutAppearance.normal.iconColor = pink
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: pink,
            .font: UIFont.systemFont(ofSize: 10, weight: .bold)
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = turquoise
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: turquoise,
            .font: UIFont.systemFont(ofSize: 10, weight: .heavy)
        ]

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
                Text("HOME")
            }
            .tag(AppTab.gym)

            NavigationStack {
                PlansView(viewModel: viewModel)
            }
            .tabItem {
                Image(systemName: "square.grid.2x2.fill")
                Text("PLANS")
            }
            .tag(AppTab.plans)

            NavigationStack {
                ProgressTabView(viewModel: viewModel)
            }
            .tabItem {
                Image(systemName: "camera.fill")
                Text("PROGRESS")
            }
            .tag(AppTab.gains)

            NavigationStack {
                SocialView()
            }
            .tabItem {
                Image(systemName: "person.fill")
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
