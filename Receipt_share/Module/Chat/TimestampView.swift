import SwiftUI

struct TimestampView: View {
  let message: ChatMessage

  var body: some View {
    HStack(spacing: 2) {
      Text(message.displayName)
      Text("@")
      Text("\(message.time, formatter: DateFormatter.timestampFormatter)")
      if !message.isUser {
        Spacer()
      }
    }
    .font(.caption)
    .foregroundColor(.green)
  }
}

#if DEBUG
struct TimestampView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      TimestampView(message: ChatMessage(displayName: "User 1", body: "Test"))
      TimestampView(message: ChatMessage(displayName: UIDevice.current.name, body: "Test"))
    }
    .padding()
  }
}
#endif
