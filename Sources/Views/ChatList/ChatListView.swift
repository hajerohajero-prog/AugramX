import SwiftUI
import Design
import ViewModels
import Core

public struct ChatListView: View {
    @StateObject public var viewModel: ChatListViewModel
    @State private var searchText = ""
    
    public init(viewModel: ChatListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background.edgesIgnoringSafeArea(.all)
                
                if viewModel.isLoading && viewModel.chats.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if viewModel.chats.isEmpty {
                    VStack {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 60))
                            .foregroundColor(DesignTokens.secondary.opacity(0.5))
                        Text("No chats yet")
                            .font(DesignTokens.headline)
                            .foregroundColor(DesignTokens.secondary)
                            .padding(.top, DesignTokens.spacingS)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.chats) { chat in
                                NavigationLink(value: chat) {
                                    ChatRow(chat: chat)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Divider()
                                    .padding(.leading, 88)
                            }
                        }
                        .padding(.top, DesignTokens.spacingS)
                    }
                    .refreshable {
                        viewModel.loadChats()
                    }
                }
            }
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search chats and messages")
            .navigationDestination(for: Chat.self) { chat in
                ChatDetailView(viewModel: ChatDetailViewModel(chat: chat, telegramService: viewModel.telegramService))
            }
            .onAppear {
                if viewModel.chats.isEmpty {
                    viewModel.loadChats()
                }
            }
        }
    }
}
