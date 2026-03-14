import SwiftUI

struct ContentView: View {
    @State private var viewModel = WorkoutViewModel()
    @State private var selectedTab: AppTab = .gym
    @State private var showWorkout: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Content area
            Group {
                switch selectedTab {
                case .gym:
                    NavigationStack {
                        HomeView(viewModel: viewModel, showWorkout: $showWorkout)
                    }
                case .plans:
                    NavigationStack {
                        PlansView(viewModel: viewModel)
                    }
                case .gains:
                    NavigationStack {
                        ProgressTabView(viewModel: viewModel)
                    }
                case .social:
                    NavigationStack {
                        SocialView()
                    }
                }
            }

            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .fullScreenCover(isPresented: $showWorkout) {
            ActiveWorkoutView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.load()
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 8) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                TabBarButton(tab: tab, isSelected: selectedTab == tab) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            // Glassmorphism floating pill
            Capsule()
                .fill(.regularMaterial)
                .overlay(
                    Capsule()
                        .fill(Color.white.opacity(0.7))
                )
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
}

struct TabBarButton: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: .semibold))

                Text(tab.title)
                    .font(.system(size: 9, weight: .bold))
            }
            .foregroundStyle(isSelected ? Y2K.turquoise : Y2K.hotPink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: Y2K.turquoise.opacity(0.3), radius: 8, y: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

enum AppTab: Hashable, CaseIterable {
    case gym
    case plans
    case gains
    case social

    var icon: String {
        switch self {
        case .gym: "sparkles"
        case .plans: "square.grid.2x2.fill"
        case .gains: "camera.fill"
        case .social: "person.fill"
        }
    }

    var title: String {
        switch self {
        case .gym: "HOME"
        case .plans: "PLANS"
        case .gains: "PROGRESS"
        case .social: "SOCIAL"
        }
    }
}
