//
//  BroadcastingManager.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 23/08/2022.
//

import Foundation
import MultipeerConnectivity

class JobConnectionManager: NSObject, ObservableObject {
  typealias JobReceivedHandler = (JobModel) -> Void
  private static let service = "jobmanager-jobs"

  @Published var employees: [MCPeerID] = []

  private var session: MCSession
  private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
  private var nearbyServiceBrowser: MCNearbyServiceBrowser
  private var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
  private let jobReceivedHandler: JobReceivedHandler?

  private var jobToSend: JobModel?
  private var peerInvitee: MCPeerID?

  init(_ jobReceivedHandler: JobReceivedHandler? = nil) {
    session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .none)
    nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(
      peer: myPeerId,
      discoveryInfo: nil,
      serviceType: JobConnectionManager.service)
    nearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: JobConnectionManager.service)
    self.jobReceivedHandler = jobReceivedHandler
    super.init()
    session.delegate = self
    nearbyServiceAdvertiser.delegate = self
    nearbyServiceBrowser.delegate = self
  }

  func startBrowsing() {
    nearbyServiceBrowser.startBrowsingForPeers()
  }

  func stopBrowsing() {
    nearbyServiceBrowser.stopBrowsingForPeers()
  }

  var isReceivingJobs: Bool = false {
    didSet {
      if isReceivingJobs {
        nearbyServiceAdvertiser.startAdvertisingPeer()
      } else {
        nearbyServiceAdvertiser.stopAdvertisingPeer()
      }
    }
  }

  func invitePeer(_ peerID: MCPeerID, to job: JobModel) {
    jobToSend = job
    let context = job.name.data(using: .utf8)
    nearbyServiceBrowser.invitePeer(peerID, to: session, withContext: context, timeout: TimeInterval(120))
  }

  private func send(_ job: JobModel, to peer: MCPeerID) {
    do {
      let data = try JSONEncoder().encode(job)
      try session.send(data, toPeers: [peer], with: .reliable)
    } catch {
      print(error.localizedDescription)
    }
  }
}

extension JobConnectionManager: MCNearbyServiceAdvertiserDelegate {
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    guard
      let window = UIApplication.shared.windows.first,
      let context = context,
      let jobName = String(data: context, encoding: .utf8)
    else { return }

    let title = "Accept \(peerID.displayName)'s Job"
    let message = "Would you like to accept: \(jobName)"
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
    alertController.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
      invitationHandler(true, self.session)
    })
    window.rootViewController?.present(alertController, animated: true)
  }
}

extension JobConnectionManager: MCNearbyServiceBrowserDelegate {
  func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
    if !employees.contains(peerID) {
      employees.append(peerID)
    }
  }

  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    guard let index = employees.firstIndex(of: peerID) else { return }
    employees.remove(at: index)
  }
}

extension JobConnectionManager: MCSessionDelegate {
  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    switch state {
    case .connected:
      guard let jobToSend = jobToSend else { return }
      send(jobToSend, to: peerID)
    case .notConnected:
      print("Not connected: \(peerID.displayName)")
    case .connecting:
      print("Connecting to: \(peerID.displayName)")
    @unknown default:
      print("Unknown state: \(state)")
    }
  }

  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    guard let job = try? JSONDecoder().decode(JobModel.self, from: data) else { return }
    DispatchQueue.main.async {
      self.jobReceivedHandler?(job)
    }
  }

  func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

  func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

  func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}


class JobListStore: ObservableObject {
  @Published var jobs: [JobModel] = []
}

struct JobModel: Codable, Identifiable {
  var id = UUID()
  let name: String
  let dueDate: Date
  let payout: String

  init(name: String, dueDate: Date, payout: String) {
    let payoutNumber = NSNumber(value: Int(payout) ?? 0)
    let payoutString = NumberFormatter.currency.string(from: payoutNumber) ?? ""
    self.name = name
    self.dueDate = dueDate
    self.payout = payoutString
  }

  func data() -> Data? {
    let encoder = JSONEncoder()
    return try? encoder.encode(self)
  }
}
