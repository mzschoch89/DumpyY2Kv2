import SwiftUI

struct ContentView: View {
    @State private var viewModel = WorkoutViewModel()
    @State private var selectedTab: AppTab = .gym
    @State private var showWorkout: Bool = false

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("HOME", systemImage: "sparkles", value: .gym) {
                NavigationStack {
                    HomeView(viewModel: viewModel, showWorkout: $showWorkout)
                }
            }

            Tab("PLANS", systemImage: "square.grid.2x2.fill", value: .plans) {
                NavigationStack {
                    PlansView(viewModel: viewModel)
                }
            }

            Tab("PROGRESS", systemImage: "camera.fill", value: .gains) {
                NavigationStack {
                    ProgressTabView(viewModel: viewModel)
                }
            }

            Tab("SOCIAL", systemImage: "person.fill", value: .social) {
                NavigationStack {
                    SocialView()
                }
            }
        }
        .tint(Y2K.turquoise)
        .tabViewStyle(.tabBarOnly)
        .tabViewSidebarHeader { EmptyView() }
        .fullScreenCover(isPresented: $showWorkout) {
            ActiveWorkoutView(viewModel: viewModel)
        }
        .onAppear {
            // Configure tab bar colors for iOS 26+ liquid glass
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            
            // Unselected items: pink
            let pink = UIColor(Y2K.hotPink)
            appearance.stackedLayoutAppearance.normal.iconColor = pink
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: pink]
            
            // Selected items: turquoise (handled by .tint)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            
            viewModel.load()
        }
    }
}

enum AppTab: Hashable {
    case gym
    case plans
    case gains
    case social
}
