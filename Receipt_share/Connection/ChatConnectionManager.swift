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
    
    @Published private(set) var refreshID = UUID()
    
    let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private var advertiserAssistant: MCNearbyServiceAdvertiser?
    private var session: MCSession?
    private var isHosting = false
    
    private var cacheManager: PersistenceController = .shared
    
    private func send(_ message: ChatMessage) {
        messages.append(message)
        guard let session = session, let data = try? Container.jsonEncoder.encode(message), !session.connectedPeers.isEmpty else { return }
        
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
        cacheManager.saveContext()

        roomId = nil
        isHosting = false
        connectedToChat = false
        messages.removeAll()

        advertiserAssistant?.stopAdvertisingPeer()
        session = nil
        advertiserAssistant = nil
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
        saveMessage(message)
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
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Receiving chat history")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        guard let localURL = localURL, let data = try? Data(contentsOf: localURL), let messages = try? Container.jsonDecoder.decode([ChatMessage].self, from: data) else { return }
        
        let sortedMessages = messages.sorted { $0.date < $1.date }
        
        DispatchQueue.main.async {
            if let roomInfo = sortedMessages.first(where: { $0.type == .roominfo }) {
                self.roomId = roomInfo.roomInfo?.id.safeUnwrapped
            }
            
            self.saveMessages(sortedMessages)
            self.messages.insert(contentsOf: sortedMessages, at: 0)
        }
    }
    
}

extension ChatConnectionManager: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.connectedToChat = true
            if let user = User.getMyUser() {
                self.sendUserInfo(user)
            }
        }
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        session?.disconnect()
        browserViewController.dismiss(animated: true)
    }
}


extension ChatConnectionManager {
    func sendReceiptInfo(_ receipt: ReceiptItem, user: User) {
        let message = ChatMessage(receipt: receipt, user: user)
        send(message)
    }
    
    func sendRoomInfo(_ room: Room) {
        let message = ChatMessage(room: room)
        send(message)
    }
    
    func sendUserInfo(_ user: User) {
        let message = ChatMessage(user: user)
        send(message)
    }
    
    func sendSelection(_ column: Selection) {
        let message = ChatMessage(selection: column)
        send(message)
    }
    
    func refresh() {
        refreshID = UUID()
    }
}

extension ChatConnectionManager {
    func parseMessage(_ message: ChatMessage) {
        debugPrint("****************")
        debugPrint(message)
        debugPrint("****************")

        switch message.type {
        case .userinfo:
            guard let userInfo = message.userInfo else { return }
            _ = User.saveRoomUser(userInfo, roomId: roomId.safeUnwrapped)
        case .receipt:
            guard let receipt = message.receipt else { return }
        case .selection:
            guard let selectionInfo = message.columnSelect else { return }
            _ = Selection.save(selectionInfo, roomId: roomId.safeUnwrapped)
        case .roominfo:
            guard let roomInfo = message.roomInfo else { return }
            _ = Room.save(roomInfo)
        }
    }
    
    func saveMessage(_ message: ChatMessage) {
        parseMessage(message)
        cacheManager.saveContext()
        
        refresh()
    }
    
    func saveMessages(_ messages: [ChatMessage]) {
        messages.forEach { message in
            parseMessage(message)
        }
        cacheManager.saveContext()
        
        refresh()
    }
}
