//
//  MessagePool.swift
//  GuessE_Tester
//
//  Created by Maksim Tochilkin on 4/1/23.
//

import Foundation
import MultipeerConnectivity

protocol Message: Codable {
    static var type: MessageType { get }
    func apply(from sender: Peer, to state: GameState)
}

class MessagePool: ObservableObject {
    let session: MCSession
    
    init(session: MCSession) {
        self.session = session
    }
    
    struct MessageWrapper: Codable {
        enum MessageKeys: CodingKey {
            case type, message
        }
        
        let type: MessageType
        let message: any Message
        
        init<M: Message>(_ message: M) {
            self.type = M.type
            self.message = message
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: MessageKeys.self)
            self.type = try container.decode(MessageType.self, forKey: .type)
            self.message = try container.decode(self.type.metatype, forKey: .message)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: MessageKeys.self)
            try container.encode(type, forKey: .type)
            try container.encode(message, forKey: .message)
        }
    }
    
    func broadcast<M: Message>(message: M) {
        do {
            let data = try JSONEncoder().encode(MessageWrapper(message))
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func receive(
        data: Data,
        _ callback: (any Message) -> Void
    ) throws {
        let wrapper = try JSONDecoder().decode(MessageWrapper.self, from: data)
        print("[Pool] new message: \(wrapper.message)")
        callback(wrapper.message)
    }
    
    func send<M: Message>(message: M, to peer: Peer) {
        do {
            let data = try JSONEncoder().encode(MessageWrapper(message))
            try session.send(data, toPeers: [peer.peerID], with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
