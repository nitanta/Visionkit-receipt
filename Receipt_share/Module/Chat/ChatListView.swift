

//import SwiftUI
//
//struct ChatListView: View {
//  @EnvironmentObject var chatConnectionManager: ChatConnectionManager
//
//  var body: some View {
//    ScrollView {
//      ScrollViewReader { reader in
//        VStack(alignment: .leading, spacing: 20) {
//          ForEach(chatConnectionManager.messages) { message in
//            MessageBodyView(message: message)
//              .onAppear {
//                if message == chatConnectionManager.messages.last {
//                  reader.scrollTo(message.id)
//                }
//              }
//          }
//        }
//        .padding(16)
//      }
//    }
//    .background(Color(UIColor.systemBackground))
//  }
//}
//
//#if DEBUG
//struct ChatListView_Previews: PreviewProvider {
//  static var previews: some View {
//    ChatListView()
//      .environmentObject(ChatConnectionManager())
//  }
//}
//#endif
