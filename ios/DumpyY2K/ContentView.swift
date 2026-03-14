import SwiftUI

struct ContentView: View {
    @State private var viewModel = WorkoutViewModel()
    @State private var selectedTab: AppTab = .gym
    @State private var showWorkout: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content area (full screen)
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

            // Floating Tab Bar (overlays content)
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
        HStack(spacing: 6) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                TabBarButton(tab: tab, isSelected: selectedTab == tab) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background {
            // Glassmorphism floating pill
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .fill(Color.white.opacity(0.85))
                )
                .shadow(color: .black.opacity(0.12), radius: 24, y: 8)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
}

struct TabBarButton: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: tab.icon)
                    .font(.system(size: 22, weight: .medium))

                Text(tab.title)
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundStyle(isSelected ? Y2K.turquoise : Y2K.hotPink)
            .frame(width: 70, height: 54)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
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
