//
//  Messages.swift
//  GuessE_Tester
//
//  Created by Maksim Tochilkin on 4/5/23.
//

import Foundation
import MultipeerConnectivity

enum MessageType: String, Codable {
    case requestToPlay, gameStateMutation, inviteAck, counterState, userGuess
    case playerReady
    
    private static let typeMap: [Self: any Message.Type] = [
        .gameStateMutation: GameStateMutation.self,
        .requestToPlay: JoinGame.self,
        .inviteAck: InviteAck.self,
        .userGuess: UserGuess.self,
        .counterState: CounterState.self,
        .playerReady: PlayerReady.self
    ]
    
    var metatype: any Message.Type {
        guard let type = Self.typeMap[self] else {
            fatalError("Not type map for: \(self)")
        }
        
        return type
    }
}

// Player -> Host
struct PlayerReady: Message {
    static var type: MessageType = .playerReady
    
    func apply(from sender: Peer, to state: GameState) {
        state.sync { shared in
            shared.players[sender] = .Ready
        }
    }
}

struct GameStateMutation: Message {
    static var type: MessageType = .gameStateMutation
    let newState: GameState.Shared
    
    func apply(from peer: Peer, to state: GameState) {
        state.shared = newState
        state.sharedDidChange()
    }
}

// Player -> Host
struct JoinGame: Message {
    static var type: MessageType = .requestToPlay
    
    let name: String
    
    func apply(from peer: Peer, to state: GameState) {
        state.sync {
            $0.names[peer] = name
            $0.players[peer] = .Joined
            $0.currentScreen[peer] = .waitRoom
        }
    }
}

struct InviteAck: Message {
    static var type: MessageType = .inviteAck
    
    func apply(from peer: Peer, to state: GameState) {
        state.sync { state in
            state.currentScreen[peer] = .joinGame
            state.players[peer] = .connected
        }
    }
}

struct UserGuess: Message {
    static var type: MessageType = .userGuess
    let guess: String
    
    func apply(from sender: Peer, to state: GameState) {
        state.sync { shared in
            shared.gueses.append(Guess(peer: sender, message: guess))
            shared.currentScreen[sender] = .waitingForRanking
            
            // count how many players are actually in the game because the
            // players dictionary just stores the status of each player
            // a player is considered "in the game" if their status is ready
            let currentPlayerCount = shared.players.reduce(0, { res, tuple in
                let (_, status) = tuple
                return res + (status == .Ready ? 1 : 0)
            })
            
            // if the number of guesses equals the number of players, that
            // means everyone has made a guess, so move the host to ranking
            // the guesses
            if shared.gueses.count == currentPlayerCount, let host = state.host {
                state.endCounter()
                state.startCounter(timerDuration: 30)
                shared.currentScreen[host] = .rankingGuesses
            }
        }
    }
}

struct CounterState: Message {
    static var type: MessageType = .counterState
    let newState: GameState.Counter
    
    func apply(from peer: Peer, to state: GameState) {
        state.counter = newState
        state.sharedDidChange()
    }
}

