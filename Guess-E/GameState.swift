//
//  GameState.swift
//  GuessE_Tester
//
//  Created by Maksim Tochilkin on 4/3/23.
//

import Foundation
import Combine
import MultipeerConnectivity

enum Screen: Hashable {
    case createSession, joinSession, waitRoom
}

final class GameState: ObservableObject {
    enum CodingKeys: String, CodingKey {
        case requests, players
    }
    
    enum PeerStatus: String, Codable, CustomStringConvertible {
        case connected, requested, Joined, Ready
        
        var description: String {
            return self.rawValue
        }
    }
    
    struct Shared: Codable {
        var names: [Peer: String] = [:]
        var players: [Peer: PeerStatus] = [:]
        var currentScreen: [Peer: GameScreen] = [:]
        var gueses: [Guess] = []
        var imageURL: URL? = nil
        var prompt: String? = nil
    }
    
    struct Counter: Codable {
        var timeElapsed: Int?
        var totalTime: Int?
        var timerEnabled: Bool
    }
    
    @Published var activeTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Published var shared: Shared = .init()
    @Published var counter: Counter = .init(
        timeElapsed: 0, totalTime: 1, timerEnabled: false
    )
    
    @Published var host: Peer? = nil
    @Published var isHost: Bool = false
    @Published var hostName: String? = nil
    
    var myCurrentScreen: GameScreen {
        get {
            shared.currentScreen[MultipeerManager.shared.myPeer] ?? .initial
        }
        set {
            shared.currentScreen[MultipeerManager.shared.myPeer] = newValue
        }
    }
    
    var myName: String {
        get {
            shared.names[MultipeerManager.shared.myPeer] ?? ""
        }
        set {
            shared.names[MultipeerManager.shared.myPeer] = newValue
        }
    }
    
    let pool: MessagePool
    
    init(pool: MessagePool) {
        self.pool = pool
    }
    
    func sync(_ mutation: (inout Shared) -> ()) {
        mutation(&shared)
        self.objectWillChange.send()
        pool.broadcast(message: GameStateMutation(newState: shared))
    }
    
    func syncCounter(_ mutation: (inout Counter) -> ()) {
        mutation(&counter)
        self.objectWillChange.send()
        pool.broadcast(message: CounterState(newState: counter))
    }

    //added for SessionWaiting
    func setPlayerReady() {
        guard let host else { return }
        pool.send(message: PlayerReady(), to: host)
    }
    
    func sharedDidChange() {
        // if the last screen was join session and we are currently in the
        // players array (meaning the host has accepted us into the game)
        // move into the wait room
        
        //        if currentScreen == .joinGame &&
        //            shared.players.contains(where: {
        //                $0 == MultipeerManager.shared.myPeer
        //            }) {
        //            currentScreen = .waitRoom
        //        }
    }
    
    func updateTimer() {
        if !(counter.timerEnabled) { return }
        
        let updatedCounterData: GameState.Counter
        
        if counter.timeElapsed! >= counter.totalTime! {
            updatedCounterData = GameState.Counter(
                timeElapsed: 0, totalTime: 20, timerEnabled: false)
        } else {
            updatedCounterData = GameState.Counter(
                timeElapsed: counter.timeElapsed! + 1,
                totalTime: counter.totalTime!, timerEnabled: true
            )
        }
        
        self.syncCounter { counter in
            counter = updatedCounterData
        }
        
        attemptMoveToNextScreen()
    }
    
    func startCounter(timerDuration: Int) {
        // Broadcast the current number of seconds left to all connected peers
        let counterData = GameState.Counter(timeElapsed: 0, totalTime: timerDuration, timerEnabled: true)
        
        self.syncCounter { counter in
            counter = counterData
        }
    }
    
    func endCounter() {
        self.syncCounter { counter in
            counter = .init(timerEnabled: false)
        }
    }
    
    func attemptMoveToNextScreen() {
        if !counter.timerEnabled {
            moveToNextScreen()
        }
    }
    
    func moveToNextScreen() {
        sync { shared in
            for key in shared.currentScreen.keys {
                if key == host {
                    let nextHostScreen = nextHostScreen(
                        currentScreen: shared.currentScreen[key]!
                    )
                    
                    if nextHostScreen == .imageCreator {
                        startCounter(timerDuration: 30)
                    } else if nextHostScreen == .waitingForGuesses {
                        startCounter(timerDuration: 30)
                    }
                    
                    shared.currentScreen[key] = nextHostScreen
                    
                    print("Moved \(key.peerID.displayName) (Host) to \(nextHostScreen)")
                } else {
                    shared.currentScreen[key] = nextPlayerScreen(
                        currentScreen: shared.currentScreen[key]!
                    )
                    print("Moved \(key.peerID.displayName) (Player) to \(String(describing: (shared.currentScreen[key])))")
                }
            }
        }
    }
    
    func timerExpired() -> Bool {
        if counter.timeElapsed! >= counter.totalTime!  {
            return true
        } else {
            return false
        }
    }
    
    func nextHostScreen(currentScreen: GameScreen) -> GameScreen{
        switch currentScreen {
        case .playerOrder:
            return .imageCreator
        case .imageCreator:
            return .waitingForGuesses
        default:
            return currentScreen
        }
    }
    
    func nextPlayerScreen(currentScreen: GameScreen) -> GameScreen{
        switch currentScreen {
        case .playerOrder:
            return .waitingForImage
        case .waitingForImage:
            return .guessingImage
        default:
            return currentScreen
        }
    }
    
}

struct Peer: Codable, Identifiable, Equatable, Hashable {
    let peerID: MCPeerID
    
    var id: Int {
        peerID.hashValue
    }
    
    init(peerID: MCPeerID) {
        self.peerID = peerID
    }
    
    enum PeerCodingError: Error {
        case failedToDecode, failedToEncode
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        let archiver = try NSKeyedUnarchiver(forReadingFrom: data)
        guard let peerID = MCPeerID(coder: archiver) else {
            throw PeerCodingError.failedToDecode
        }
        self.peerID = peerID
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let archiver = NSKeyedArchiver(requiringSecureCoding: false)
        peerID.encode(with: archiver)
        try container.encode(archiver.encodedData)
    }
    
}
