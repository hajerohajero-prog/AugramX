import SwiftUI
import Design
import ViewModels

public struct ChatDetailView: View {
    @StateObject public var viewModel: ChatDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    
    public init(viewModel: ChatDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            DesignTokens.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                if viewModel.isLoading && viewModel.messages.isEmpty {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Spacer()
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                            }
                            .padding(.vertical, DesignTokens.spacingS)
                        }
                        .onChange(of: viewModel.messages.count) { _ in
                            if let last = viewModel.messages.last {
                                withAnimation {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
                ComposerView(text: $viewModel.messageText, onSend: {
                    viewModel.sendMessage()
                })
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        
                        HStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 32, height: 32)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text(viewModel.chat.title)
                                    .font(DesignTokens.headline)
                                    .foregroundColor(DesignTokens.primary)
                                Text("online")
                                    .font(.system(size: 12))
                                    .foregroundColor(DesignTokens.accent)
                            }
                        }
                    }
                    .foregroundColor(DesignTokens.primary)
                }
            }
        }
        .onAppear {
            viewModel.loadMessages()
        }
    }
}
