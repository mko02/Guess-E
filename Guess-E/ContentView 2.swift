//
//  ContentView.swift
//  GuessE_Tester
//
//  Created by Maksim Tochilkin on 3/21/23.
//

import SwiftUI
import MultipeerConnectivity

//{
//  "prompt": "A cute baby sea otter",
//  "n": 2,
//  "size": "1024x1024"
//}

struct ImageGenBody: Encodable {
    enum Size: String, Encodable {
        case small = "256x256"
        case medium = "512x512"
        case large = "1024x1024"
    }
    
    let prompt: String
    let n: Int
    let size: Size
}

//{
//  "created": 1589478378,
//  "data": [
//    {
//      "url": "https://..."
//    },
//    {
//      "url": "https://..."
//    }
//  ]
//}

struct ImageGenResponse: Decodable {
    let created: Date
    let data: [[String: URL]]
}

//AsyncImage(url: imageURL)
//    .task {
//        do {
//            let body = ImageGenBody(
//                prompt: "A stampler conquering Mars", n: 1, size: .small
//            )
//            let url = URL(string: "https://api.openai.com/v1/images/generations")!
//            var req = URLRequest(url: url)
//            req.httpMethod = "POST"
//            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            req.setValue("Bearer \(API_TOKEN)", forHTTPHeaderField: "Authorization")
//            req.httpBody = try JSONEncoder().encode(body)
//            let (data, _) = try await URLSession.shared.data(for: req)
//            let res = try JSONDecoder().decode(ImageGenResponse.self, from: data)
//            print(res)
//            self.imageURL = res.data[0]["url"]
//
//        } catch {
//            print(error)
//        }
//    }


struct ContentView: View {
    @EnvironmentObject var state: GameState
    
    var body: some View {
        NavigationStack(path: $state.navPath) {
            VStack {
                Text("Welcome to Guess-E")
                HStack {
                    Button("Create Session") {
                        state.navPath = [.createSession]
                    }
                    
                    Button("Join Session") {
                        state.navPath = [.joinSession]
                    }
                }
            }
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
                case .createSession:
                    CreateGameView()
                case .joinSession:
                    JoinGameView()
                case .waitRoom:
                    WaitRoom()
                }
            }
        }
    }
}

struct JoinGameView: View {
    @EnvironmentObject var multipeerManager: MultipeerManager
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var pool: MessagePool
    
    var body: some View {
        VStack {
            Section("Discovered hosts:") {
                List {
                    ForEach(multipeerManager.hosts) { host in
                        HStack {
                            Text(host.name)
                            Spacer()
                            // we don't have a shared game state since we are not
                            // in the game yet, so have to send request to specific
                            // host
                            Button("Request to join") {
                                pool.send(message: RequestToPlay(), to: host)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Join a game")
        .onAppear {
            multipeerManager.startAdvertising()
        }
        .onDisappear {
            multipeerManager.stopAdvertising()
        }
    }
}

struct CreateGameView: View {
    @EnvironmentObject var multipeerManager: MultipeerManager
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var pool: MessagePool
    
    var body: some View {
        VStack {
            Section("Player requests") {
                List(gameState.shared.requests) { peer in
                    VStack {
                        Text(peer.name)
                        HStack {
                            Button("Accept") {
                                gameState.sync {
                                    $0.requests.removeAll(where: {
                                        $0 == peer
                                    })
                                    
                                    $0.players.append(peer)
                                }
                            }
                            Spacer()
                            Button("Reject") {
                                gameState.sync {
                                    $0.requests.removeAll(where: {
                                        $0 == peer
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Create a game")
        .onAppear {
            multipeerManager.startBrowsing()
        }
        .onDisappear {
            multipeerManager.stopBrowsing()
        }
    }
}



struct WaitRoom: View {
    @EnvironmentObject var state: GameState
    @EnvironmentObject var multipeerManager: MultipeerManager

    var body: some View {
        List {
            ForEach(state.shared.requests) { requestPeer in
                HStack {
                    Text(requestPeer.name)
                    Spacer()
                    Text("⏳")
                }
            }
            
            ForEach(state.shared.players) { player in
                HStack {
                    Text(player.name)
                    Spacer()
                    Text(player == multipeerManager.myPeer ? "👑" : "✅")
                }

            }
        }
    }
}
