
//
//import SwiftUI
//
//struct MessageBodyView: View {
//  let message: ChatMessage
//
//  var body: some View {
//    HStack {
//      if message.isUser {
//        Spacer()
//      }
//      VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
//        Text(message.body)
//          .font(.body)
//          .padding(8)
//          .foregroundColor(.white)
//          .background(message.isUser ? .green : .gray)
//          .cornerRadius(9)
//        TimestampView(message: message)
//      }
//    }
//  }
//}
//
//#if DEBUG
//struct MessageBodyView_Previews: PreviewProvider {
//  static var previews: some View {
//    VStack {
//      MessageBodyView(message: ChatMessage(displayName: "User 1", body: "Test"))
//      MessageBodyView(message: ChatMessage(displayName: UIDevice.current.name, body: "Test"))
//    }
//    .padding()
//  }
//}
//#endif
