import SwiftUI

struct ContentView: View {
    @State private var viewModel = WorkoutViewModel()
    @State private var selectedTab: Int = 0
    @State private var showWorkout: Bool = false

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(viewModel: viewModel, showWorkout: $showWorkout)
            }
            .tabItem {
                Label("HOME", systemImage: "sparkles")
                    .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
            }
            .tag(0)

            NavigationStack {
                PlansView(viewModel: viewModel)
            }
            .tabItem {
                Label("PLANS", systemImage: "square.grid.2x2.fill")
            }
            .tag(1)

            NavigationStack {
                ProgressTabView(viewModel: viewModel)
            }
            .tabItem {
                Label("PROGRESS", systemImage: "camera.fill")
            }
            .tag(2)

            NavigationStack {
                SocialView()
            }
            .tabItem {
                Label("SOCIAL", systemImage: "person.fill")
            }
            .tag(3)
        }
        .tint(Y2K.turquoise)
        .onAppear {
            // Set unselected tab color
            let pink = UIColor(Y2K.hotPink)
            UITabBar.appearance().unselectedItemTintColor = pink
            viewModel.load()
        }
        .fullScreenCover(isPresented: $showWorkout) {
            ActiveWorkoutView(viewModel: viewModel)
        }
    }
}
