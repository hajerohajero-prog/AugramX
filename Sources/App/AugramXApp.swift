import SwiftUI
import Design
import ViewModels
import Views

@main
struct AugramXApp: App {
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var theme = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            switch coordinator.flow {
            case .onboarding:
                OnboardingView()
                    .environmentObject(coordinator)
                    .environmentObject(theme)
            case .auth:
                let authVM = AuthViewModel(telegramService: coordinator.telegramService)
                AuthView(viewModel: authVM)
                    .environmentObject(coordinator)
                    .environmentObject(theme)
            case .chatList:
                let chatVM = ChatListViewModel(telegramService: coordinator.telegramService)
                ChatListView(viewModel: chatVM)
                    .environmentObject(coordinator)
                    .environmentObject(theme)
            }
        }
    }
}
