import SwiftUI

struct ContentView: View {
    @State private var viewModel = WorkoutViewModel()
    @State private var selectedTab: AppTab = .gym
    @State private var showWorkout: Bool = false

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: .gym) {
                NavigationStack {
                    HomeView(viewModel: viewModel, showWorkout: $showWorkout)
                }
            } label: {
                TabLabel(icon: "sparkles", title: "HOME", isSelected: selectedTab == .gym)
            }

            Tab(value: .plans) {
                NavigationStack {
                    PlansView(viewModel: viewModel)
                }
            } label: {
                TabLabel(icon: "square.grid.2x2.fill", title: "PLANS", isSelected: selectedTab == .plans)
            }

            Tab(value: .gains) {
                NavigationStack {
                    ProgressTabView(viewModel: viewModel)
                }
            } label: {
                TabLabel(icon: "camera.fill", title: "PROGRESS", isSelected: selectedTab == .gains)
            }

            Tab(value: .social) {
                NavigationStack {
                    SocialView()
                }
            } label: {
                TabLabel(icon: "person.fill", title: "SOCIAL", isSelected: selectedTab == .social)
            }
        }
        .tabViewStyle(.tabBarOnly)
        .fullScreenCover(isPresented: $showWorkout) {
            ActiveWorkoutView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.load()
        }
    }
}

struct TabLabel: View {
    let icon: String
    let title: String
    let isSelected: Bool

    var body: some View {
        Label {
            Text(title)
                .foregroundStyle(isSelected ? Y2K.turquoise : Y2K.hotPink)
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(isSelected ? Y2K.turquoise : Y2K.hotPink)
        }
    }
}

enum AppTab: Hashable {
    case gym
    case plans
    case gains
    case social
}
