import SwiftUI
import Design
import ViewModels

public struct OnboardingView: View {
    @EnvironmentObject public var coordinator: AppCoordinator
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: DesignTokens.spacingL) {
            Spacer()
            
            Text("AugramX")
                .font(DesignTokens.title)
                .foregroundColor(DesignTokens.primary)
            
            Text("A premium custom Telegram client.\nUses official TDLib and Telegram backend.")
                .font(DesignTokens.body)
                .multilineTextAlignment(.center)
                .foregroundColor(DesignTokens.secondary)
                .padding(.horizontal, DesignTokens.spacingL)
            
            Spacer()
            
            Button(action: {
                coordinator.startAuth()
            }) {
                Text("Войти в Telegram")
                    .font(DesignTokens.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(DesignTokens.accent)
                    .cornerRadius(DesignTokens.cornerRadius)
            }
            .padding(DesignTokens.spacingL)
        }
        .background(DesignTokens.background.edgesIgnoringSafeArea(.all))
    }
}
