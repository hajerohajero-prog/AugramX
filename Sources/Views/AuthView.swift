import SwiftUI
import Design
import ViewModels
import Core

public struct AuthView: View {
    @StateObject public var viewModel: AuthViewModel
    @EnvironmentObject public var coordinator: AppCoordinator
    
    @State private var currentState: TelegramAuthState = .waitingPhoneNumber
    
    public init(viewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            DesignTokens.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: DesignTokens.spacingM) {
                Text("AugramX")
                    .font(DesignTokens.title)
                    .foregroundColor(DesignTokens.primary)
                    .padding(.top, 60)
                
                Text("Telegram Authentication")
                    .font(DesignTokens.headline)
                    .foregroundColor(DesignTokens.secondary)
                
                Spacer()
                
                GlassSurface(cornerRadius: 16, material: .regular, strokeColor: Color.white.opacity(0.15)) {
                    VStack(spacing: DesignTokens.spacingM) {
                        switch currentState {
                        case .waitingPhoneNumber, .idle:
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Enter Phone Number")
                                    .font(DesignTokens.body)
                                    .foregroundColor(DesignTokens.primary)
                                
                                TextField("+1234567890", text: $viewModel.phoneNumber)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.phonePad)
                                
                                Button(action: {
                                    viewModel.submitPhone()
                                }) {
                                    Text("Send Code")
                                        .font(DesignTokens.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(DesignTokens.accent)
                                        .cornerRadius(DesignTokens.cornerRadius)
                                }
                                .padding(.top, 8)
                            }
                            
                        case .waitingCode:
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Enter SMS Code")
                                    .font(DesignTokens.body)
                                    .foregroundColor(DesignTokens.primary)
                                
                                TextField("Code", text: $viewModel.code)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                                
                                Button(action: {
                                    viewModel.submitCode()
                                }) {
                                    Text("Verify Code")
                                        .font(DesignTokens.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(DesignTokens.accent)
                                        .cornerRadius(DesignTokens.cornerRadius)
                                }
                                .padding(.top, 8)
                            }
                            
                        case .waitingPassword:
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Enter 2FA Password")
                                    .font(DesignTokens.body)
                                    .foregroundColor(DesignTokens.primary)
                                
                                SecureField("Password", text: $viewModel.password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button(action: {
                                    viewModel.submitPassword()
                                }) {
                                    Text("Submit Password")
                                        .font(DesignTokens.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(DesignTokens.accent)
                                        .cornerRadius(DesignTokens.cornerRadius)
                                }
                                .padding(.top, 8)
                            }
                            
                        case .ready:
                            ProgressView("Connecting...")
                                .foregroundColor(DesignTokens.primary)
                            
                        case .error(let msg):
                            VStack(spacing: 8) {
                                Text("Error: \(msg)")
                                    .foregroundColor(.red)
                                    .font(DesignTokens.caption)
                                
                                Button("Retry") {
                                    viewModel.submitPhone()
                                }
                            }
                        }
                    }
                    .padding(DesignTokens.spacingL)
                }
                .padding(.horizontal, DesignTokens.spacingL)
                
                Spacer()
            }
        }
        .onReceive(coordinator.telegramService.authState) { state in
            self.currentState = state
        }
    }
}
