////
////  ChatConnectionManager.swift
////  Receipt_share
////
////  Created by Nitanta Adhikari on 23/08/2022.
////
//
//import Foundation
//import MultipeerConnectivity
//
//class ChatConnectionManager: NSObject, ObservableObject {
//  private static let service = "jobmanager-chat"
//
//  @Published var messages: [ChatMessage] = []
//  @Published var peers: [MCPeerID] = []
//  @Published var connectedToChat = false
//
//  let myPeerId = MCPeerID(displayName: UIDevice.current.name)
//  private var advertiserAssistant: MCNearbyServiceAdvertiser?
//  private var session: MCSession?
//  private var isHosting = false
//
//  func send(_ message: String) {
//    let chatMessage = ChatMessage(displayName: myPeerId.displayName, body: message)
//    messages.append(chatMessage)
//    guard
//      let session = session,
//      let data = message.data(using: .utf8),
//      !session.connectedPeers.isEmpty
//    else { return }
//
//    do {
//      try session.send(data, toPeers: session.connectedPeers, with: .reliable)
//    } catch {
//      print(error.localizedDescription)
//    }
//  }
//
//  func sendHistory(to peer: MCPeerID) {
//    let tempFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("messages.data")
//    guard let historyData = try? JSONEncoder().encode(messages) else { return }
//    try? historyData.write(to: tempFile)
//    session?.sendResource(at: tempFile, withName: "Chat_History", toPeer: peer) { error in
//      if let error = error {
//        print(error.localizedDescription)
//      }
//    }
//  }
//
//  func join() {
//    peers.removeAll()
//    messages.removeAll()
//    session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
//    session?.delegate = self
//    guard
//      let window = UIApplication.shared.windows.first,
//      let session = session
//    else { return }
//
//    let mcBrowserViewController = MCBrowserViewController(serviceType: ChatConnectionManager.service, session: session)
//    mcBrowserViewController.delegate = self
//    window.rootViewController?.present(mcBrowserViewController, animated: true)
//  }
//
//  func host() {
//    isHosting = true
//    peers.removeAll()
//    messages.removeAll()
//    connectedToChat = true
//    session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
//    session?.delegate = self
//    advertiserAssistant = MCNearbyServiceAdvertiser(
//      peer: myPeerId,
//      discoveryInfo: nil,
//      serviceType: ChatConnectionManager.service)
//    advertiserAssistant?.delegate = self
//    advertiserAssistant?.startAdvertisingPeer()
//  }
//
//  func leaveChat() {
//    isHosting = false
//    connectedToChat = false
//    advertiserAssistant?.stopAdvertisingPeer()
//    messages.removeAll()
//    session = nil
//    advertiserAssistant = nil
//  }
//}
//
//extension ChatConnectionManager: MCNearbyServiceAdvertiserDelegate {
//  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
//      let title = "Accept \(peerID.displayName)"
//      let message = "Would you like to accept collbration from : \(peerID.displayName)"
//      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//      alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
//      alertController.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
//        invitationHandler(true, self.session)
//      })
//      rootController().present(alertController, animated: true)
//    }
//
//    func rootController() -> UIViewController {
//        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return .init() }
//        guard let root = scene.windows.first?.rootViewController else { return .init() }
//        return root
//    }
//}
//
//extension ChatConnectionManager: MCSessionDelegate {
//  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
//    guard let message = String(data: data, encoding: .utf8) else { return }
//    let chatMessage = ChatMessage(displayName: peerID.displayName, body: message)
//    DispatchQueue.main.async {
//      self.messages.append(chatMessage)
//    }
//  }
//
//  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
//    switch state {
//    case .connected:
//      if !peers.contains(peerID) {
//        DispatchQueue.main.async {
//          self.peers.insert(peerID, at: 0)
//        }
//        if isHosting {
//          sendHistory(to: peerID)
//        }
//      }
//    case .notConnected:
//      DispatchQueue.main.async {
//        if let index = self.peers.firstIndex(of: peerID) {
//          self.peers.remove(at: index)
//        }
//        if self.peers.isEmpty && !self.isHosting {
//          self.connectedToChat = false
//        }
//      }
//    case .connecting:
//      print("Connecting to: \(peerID.displayName)")
//    @unknown default:
//      print("Unknown state: \(state)")
//    }
//  }
//
//  func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
//
//  func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
//    print("Receiving chat history")
//  }
//
//  func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
//    guard
//      let localURL = localURL,
//      let data = try? Data(contentsOf: localURL),
//      let messages = try? JSONDecoder().decode([ChatMessage].self, from: data)
//    else { return }
//
//    DispatchQueue.main.async {
//      self.messages.insert(contentsOf: messages, at: 0)
//    }
//  }
//}
//
//extension ChatConnectionManager: MCBrowserViewControllerDelegate {
//  func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
//    browserViewController.dismiss(animated: true) {
//      self.connectedToChat = true
//    }
//  }
//
//  func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
//    session?.disconnect()
//    browserViewController.dismiss(animated: true)
//  }
//}
//
//import UIKit
//
//struct ChatMessage: Identifiable, Equatable, Codable {
//  var id = UUID()
//  let displayName: String
//  let body: String
//  var time = Date()
//
//  var isUser: Bool {
//    return displayName == UIDevice.current.name
//  }
//}

//
//  ChatConnectionManager.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 23/08/2022.
//

import Foundation
import MultipeerConnectivity

class ChatConnectionManager: NSObject, ObservableObject {
    private static let service = "jobmanager-chat"
    
    @Published var messages: [ChatMessage] = []
    @Published var peers: [MCPeerID] = []
    @Published var connectedToChat = false
    @Published var roomId: String? = nil
    
    let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private var advertiserAssistant: MCNearbyServiceAdvertiser?
    private var session: MCSession?
    private var isHosting = false
    
    private func send(_ message: ChatMessage) {
        messages.append(message)
        guard let session = session, let data = try? Container.jsonEncoder.encode(message), !session.connectedPeers.isEmpty
        else { return }
        
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func sendHistory(to peer: MCPeerID) {
        let tempFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("messages.data")
        guard let historyData = try? JSONEncoder().encode(messages) else { return }
        try? historyData.write(to: tempFile)
        session?.sendResource(at: tempFile, withName: "Chat_History", toPeer: peer) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func join() {
        peers.removeAll()
        messages.removeAll()
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
        guard let window = UIApplication.shared.windows.first, let session = session else { return }
        
        let mcBrowserViewController = MCBrowserViewController(serviceType: ChatConnectionManager.service, session: session)
        mcBrowserViewController.delegate = self
        window.rootViewController?.present(mcBrowserViewController, animated: true)
    }
    
    func host(_ room_id: String) {
        roomId = room_id
        isHosting = true
        peers.removeAll()
        messages.removeAll()
        connectedToChat = true
        
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
        advertiserAssistant = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ChatConnectionManager.service)
        advertiserAssistant?.delegate = self
        advertiserAssistant?.startAdvertisingPeer()
    }
    
    func leaveChat() {
        roomId = nil
        isHosting = false
        connectedToChat = false
        messages.removeAll()

        advertiserAssistant?.stopAdvertisingPeer()
        session = nil
        advertiserAssistant = nil
    }
}

extension ChatConnectionManager {
    func sendReceiptInfo(_ receipt: ReceiptItem, user: User) {
        let message = ChatMessage(receipt: receipt, user: user)
        send(message)
    }
    
    func sendUserInfo(_ user: User) {
        let message = ChatMessage(user: user)
        send(message)
    }
    
    func sendSelection(_ column: Column, user: User) {
        let message = ChatMessage(column: column, user: user)
        send(message)
    }
}

extension ChatConnectionManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        let title = "Accept \(peerID.displayName)"
        let message = "Would you like to accept collbration from : \(peerID.displayName)"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            invitationHandler(true, self.session)
        })
        rootController().present(alertController, animated: true)
    }
    
    private func rootController() -> UIViewController {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return .init() }
        guard let root = scene.windows.first?.rootViewController else { return .init() }
        return root
    }
    
}

extension ChatConnectionManager: MCSessionDelegate {
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = try? Container.jsonDecoder.decode(ChatMessage.self, from: data) else { return }
        DispatchQueue.main.async {
            self.messages.append(message)
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            if !peers.contains(peerID) {
                DispatchQueue.main.async {
                    self.peers.insert(peerID, at: 0)
                }
                if isHosting {
                    sendHistory(to: peerID)
                }
            }
        case .notConnected:
            DispatchQueue.main.async {
                if let index = self.peers.firstIndex(of: peerID) {
                    self.peers.remove(at: index)
                }
                if self.peers.isEmpty && !self.isHosting {
                    self.connectedToChat = false
                }
            }
        case .connecting:
            print("Connecting to: \(peerID.displayName)")
        @unknown default:
            print("Unknown state: \(state)")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Receiving chat history")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        guard let localURL = localURL, let data = try? Data(contentsOf: localURL), let messages = try? JSONDecoder().decode([ChatMessage].self, from: data) else { return }
        
        DispatchQueue.main.async {
            self.messages.insert(contentsOf: messages, at: 0)
        }
    }
    
}

extension ChatConnectionManager: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true) {
            self.connectedToChat = true
        }
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        session?.disconnect()
        browserViewController.dismiss(animated: true)
    }
}
