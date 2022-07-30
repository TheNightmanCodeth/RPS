//
//  RPSMultipeerSession.swift
//  RPS
//
//  Created by Joe Diragi on 7/28/22.
//

import MultipeerConnectivity
import os

enum Move: String, CaseIterable {
    case rock, paper, scissors, unknown, pair
}

class RPSMultipeerSession: NSObject, ObservableObject {
    private let serviceType = "rps-service"
    private var myPeerID: MCPeerID
    
    //public let serviceAdvertiser: MCNearbyServiceAdvertiser
    public let serviceBrowser: MCNearbyServiceBrowser
    public let session: MCSession
    
    public let advertiserAssistant: MCAdvertiserAssistant
    
    private let log = Logger()
    
    @Published var connectedPeer: MCPeerID? = nil
    @Published var availablePeers: [MCPeerID] = []
    @Published var receivedMove: Move = .unknown
    @Published var username: String
    @Published var recvdInvite: Bool = false
    @Published var recvdInviteFrom: MCPeerID? = nil
    @Published var paired: Bool = false
    
    init(username: String) {
        self.username = username
        let peerID = MCPeerID(displayName: username)
        self.myPeerID = peerID
        
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        //serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        advertiserAssistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)
        super.init()
        
        session.delegate = self
        //serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
        advertiserAssistant.delegate = self
        
        advertiserAssistant.start()
                
        //serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        //serviceAdvertiser.stopAdvertisingPeer()
        advertiserAssistant.stop()
        serviceBrowser.stopBrowsingForPeers()
    }
    
    func send(move: Move) {
        log.info("sendColor: \(String(describing: move)) to \(self.session.connectedPeers.count) peers")
        
        if !session.connectedPeers.isEmpty {
            do {
                try session.send(move.rawValue.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                log.error("Error sending: \(String(describing: error))")
            }
        }
    }
    
    func start() {
        if !session.connectedPeers.isEmpty {
            log.info("Sending start ping to \(self.session.connectedPeers[0].displayName)")
            do {
                try session.send("Start".data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                log.error("Error sending: \(String(describing: error))")
            }
        }
    }
}

/*
extension RPSMultipeerSession: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        log.error("ServiceAdvertiser didNotStartAdvertisingPeer: \(String(describing: error))")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        log.info("didReceiveInvitationFromPeer \(peerID)")
        // TODO: Ask to accept invitation from peer
        DispatchQueue.main.async {
            self.recvdInvite = true
            self.recvdInviteFrom = peerID
        }
    }
}
 */

extension RPSMultipeerSession: MCAdvertiserAssistantDelegate {
    func advertiserAssistantDidDismissInvitation(_ advertiserAssistant: MCAdvertiserAssistant) {
        log.info("didDismissInvitation")
    }
    
    func advertiserAssistantWillPresentInvitation(_ advertiserAssistant: MCAdvertiserAssistant) {
        log.info("willPresentInvitation")
    }
}

extension RPSMultipeerSession: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        log.error("ServiceBroser didNotStartBrowsingForPeers: \(String(describing: error))")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        log.info("ServiceBrowser found peer: \(peerID)")
        
        DispatchQueue.main.async {
            self.availablePeers.append(peerID)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        log.info("ServiceBrowser lost peer: \(peerID)")
        DispatchQueue.main.async {
            self.availablePeers.removeAll(where: {
                $0 == peerID
            })
        }
    }
}

extension RPSMultipeerSession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        log.info("peer \(peerID) didChangeState: \(state.rawValue)")
        switch state {
        case MCSessionState.notConnected:
            // Peer disconnected
            DispatchQueue.main.async {
                self.paired = false
            }
            break
        case MCSessionState.connected:
            // Peer connected
            DispatchQueue.main.async {
                self.paired = true
            }
            break
        default:
            // Peer connecting
            DispatchQueue.main.async {
                self.paired = false
            }
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let string = String(data: data, encoding: .utf8), let move = Move(rawValue: string) {
            log.info("didReceive move \(string)")
            DispatchQueue.main.async {
                self.receivedMove = move
            }
        } else if let string = String(data: data, encoding: .utf8) {
            log.info("didReceive start ping")
            if (string == "Start") {
                DispatchQueue.main.async {
                    self.paired = true
                }
            }
        } else {
            log.info("didReceive invalid value \(data.count) bytes")
        }
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        log.error("Receiving streams is not supported")
    }
    
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        log.error("Receiving resources is not supported")
    }
    
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        log.error("Receiving resources is not supported")
    }
    
    public func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}
