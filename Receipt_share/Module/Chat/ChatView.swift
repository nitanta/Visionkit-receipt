
import SwiftUI

struct ChatView: View {
  @EnvironmentObject var chatConnectionManager: ChatConnectionManager
  @State private var messageText = ""

  var body: some View {
    VStack {
      chatInfoView
      ChatListView()
        .environmentObject(chatConnectionManager)
      messageField
    }
    .navigationBarTitle("Chat", displayMode: .inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button("Leave") {
          chatConnectionManager.leaveChat()
        }
      }
    }
    .navigationBarBackButtonHidden(true)
  }

  private var messageField: some View {
    VStack(spacing: 0) {
      Divider()
      // swiftlint:disable:next trailing_closure
      TextField("Enter Message", text: $messageText, onCommit: {
        guard !messageText.isEmpty else { return }
        chatConnectionManager.send(messageText)
        messageText = ""
      })
      .padding()
    }
  }

  private var chatInfoView: some View {
      VStack(alignment: .leading) {
          Divider()
          HStack {
              Text("People in chat:")
                  .fixedSize(horizontal: true, vertical: false)
                  .font(.headline)
              if chatConnectionManager.peers.isEmpty {
                  Text("Empty")
                      .font(Font.caption.italic())
                      .foregroundColor(.gray)
              } else {
                  chatParticipants
              }
          }
          .padding(.top, 8)
          .padding(.leading, 16)
          Divider()
      }
    .frame(height: 44)
  }

  private var chatParticipants: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack {
        ForEach(chatConnectionManager.peers, id: \.self) { peer in
          Text(peer.displayName)
            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 6)
            .background(.green)
            .foregroundColor(.gray)
            .font(Font.body.bold())
            .cornerRadius(9)
        }
      }
    }
  }
}

#if DEBUG
import MultipeerConnectivity
struct ChatView_Previews: PreviewProvider {
  static let chatConnectionManager = ChatConnectionManager()

  static var previews: some View {
    NavigationView {
      ChatView()
        .environmentObject(chatConnectionManager)
        .onAppear {
          chatConnectionManager.peers.append(MCPeerID(displayName: "Test Peer"))
        }
    }
  }
}
#endif
