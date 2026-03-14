import SwiftUI

struct ContentView: View {
    @State private var viewModel = WorkoutViewModel()
    @State private var selectedTab: AppTab = .gym
    @State private var showWorkout: Bool = false

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
        .onAppear {
            // Force tab bar appearance after view is created
            DispatchQueue.main.async {
                let scenes = UIApplication.shared.connectedScenes
                if let windowScene = scenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let tabBarController = window.rootViewController?.children.first(where: { $0 is UITabBarController }) as? UITabBarController {
                    tabBarController.tabBar.unselectedItemTintColor = UIColor(Y2K.hotPink)
                    tabBarController.tabBar.tintColor = UIColor(Y2K.turquoise)
                } else {
                    // Fallback: apply to all tab bars via appearance
                    UITabBar.appearance().unselectedItemTintColor = UIColor(Y2K.hotPink)
                }
            }
            viewModel.load()
        }
        .fullScreenCover(isPresented: $showWorkout) {
            ActiveWorkoutView(viewModel: viewModel)
        }
    }
}

nonisolated enum AppTab: Hashable, Sendable {
    case gym
    case plans
    case gains
    case social
}
