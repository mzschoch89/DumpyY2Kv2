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
        HStack {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Spacer()
                TabBarButton(tab: tab, isSelected: selectedTab == tab) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }
                Spacer()
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background {
            // Glassmorphism effect
            ZStack {
                // Blur background
                Rectangle()
                    .fill(.ultraThinMaterial)

                // Gradient overlay for Y2K vibe
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.95, blue: 0.96).opacity(0.8),
                        Color(red: 1.0, green: 0.92, blue: 0.95).opacity(0.6)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Top border shine
                VStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.6), .white.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 1)
                    Spacer()
                }
            }
        }
        .shadow(color: Y2K.hotPink.opacity(0.1), radius: 20, y: -10)
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
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? Y2K.turquoise : Y2K.hotPink)

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .heavy : .bold))
                    .foregroundStyle(isSelected ? Y2K.turquoise : Y2K.hotPink)
            }
        }
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
