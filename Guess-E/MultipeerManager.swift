//
//  MultipeerManager.swift
//  GuessE_Tester
//
//  Created by Maksim Tochilkin on 4/3/23.
//
import SwiftUI
import MultipeerConnectivity

struct AppData {
    var name: String = ""
}

//class AppState: ObservableObject {
//    let state: GameState
//    let manager: MultipeerManager
//}

class MultipeerManager: NSObject, ObservableObject {
    static let shared = MultipeerManager()

    let myPeer = Peer(
        peerID: MCPeerID(displayName: UIDevice.current.name)
    )
    
    private let serviceType = "guess-e"

    var hostState: GameState!
    
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!
    var pool: MessagePool!

    @Published var connectedPlayers: [MCPeerID] = []
    @Published var hosts: [Peer: GameState] = [:]
    @Published var hostNames: [Peer: String] = [:]
    @Published var data: AppData = .init()

    private override init() {
        super.init()
        setupSession()
        setupAdvertiser()
        setupBrowser()
    }

    func setupSession() {
        session = MCSession(
            peer: myPeer.peerID,
            securityIdentity: nil,
            encryptionPreference: .none
        )
        session.delegate = self
        pool = MessagePool(session: session)
        hostState = GameState(pool: pool)
        hostState.isHost = true
        hostState.host = myPeer
        // TODO: Name for host state?
    }

    func setupAdvertiser() {
        advertiser = MCNearbyServiceAdvertiser(
            peer: myPeer.peerID, discoveryInfo: nil, serviceType: serviceType
        )
        advertiser.delegate = self
    }

    func setupBrowser() {
        browser = MCNearbyServiceBrowser(
            peer: myPeer.peerID, serviceType: serviceType
        )
        browser.delegate = self
    }
}

extension MultipeerManager: MCSessionDelegate {
    func session(
        _ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID
    ) {
        do {
            try pool.receive(data: data) { m in
                DispatchQueue.main.async { [unowned self] in
                    let peer = Peer(peerID: peerID)
                    
                    let messageType = type(of: m).type
                    
                    if  messageType == .gameStateMutation ||
                        messageType == .counterState {
                        
                        // Host -> Player since game state mutation is a part of `sync`
                        // which is only called from the host
                        
                        guard let state = self.hosts[peer] else {
                            return
                        }
                        
                        m.apply(from: peer, to: state)
                        
                    } else {
                        // Player -> Host
                        m.apply(from: peer, to: hostState)
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String, fromPeer peerID: MCPeerID
    ) {
        
    }
    
    func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, with progress: Progress
    ) {
        
    }
    
    func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: Error?
    ) {
        
    }
    
    func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        print("[Session] \(peerID.displayName) => \(state)")
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.connectedPlayers.append(peerID)
            case .notConnected:
                if let index = self.connectedPlayers.firstIndex(of: peerID) {
                    self.connectedPlayers.remove(at: index)
                }
            default:
                break
            }
        }
    }
}

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        print("[Advertiser] accepting invitation from \(peerID.displayName)")
        let peer = Peer(peerID: peerID)
        let newState = GameState(pool: pool)
        
        if let context {
            let name = String(data: context, encoding: .utf8)
            hostNames[peer] = name
            newState.hostName = name
            
            print("[Advertiser] host name: \(name)")
        }
            
        hosts[peer] = newState
        invitationHandler(true, self.session)
        pool.send(message: InviteAck(), to: Peer(peerID: peerID))
    }
    
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didNotStartAdvertisingPeer error: Error
    ) {
        print("[Advertiser] \(error.localizedDescription)")
    }
}

extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String : String]?
    ) {
        print("[Browser] discoverd peer: \(peerID.displayName)")
        
        // automatically invites discovered players to host's session
        let context = data.name.data(using: .utf8)
        browser.invitePeer(
            peerID, to: self.session, withContext: context, timeout: 10
        )
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("[Browser] lost peer: \(peerID.displayName)")
    }
    
    func browser(
        _ browser: MCNearbyServiceBrowser,
        didNotStartBrowsingForPeers error: Error
    ) {
        print("[Browser] \(error.localizedDescription)")
    }
}

extension MultipeerManager {
    func startAdvertising() {
        advertiser.startAdvertisingPeer()
    }
    
    func stopAdvertising() {
        advertiser.stopAdvertisingPeer()
    }
    
    func startBrowsing() {
        browser.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        browser.stopBrowsingForPeers()
    }
    
    func invite(peer: MCPeerID) {
        browser.invitePeer(peer, to: session, withContext: nil, timeout: 10)
    }
    
    func getMyPeerID() -> MCPeerID {
        return myPeer.peerID
    }
    
}

extension MCSessionState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notConnected:
            return "Not Connected"
        case .connecting:
            return "Connecting"
        case .connected:
            return "Connected"
        @unknown default:
            return "Unknown"
        }
    }
}
