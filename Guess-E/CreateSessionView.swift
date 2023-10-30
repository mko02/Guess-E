//
//  CreateSessionView.swift
//  Guess-E
//
//  Created by Max Ko on 3/30/23.
//

import SwiftUI

class Player: ObservableObject, Identifiable {
    var name: String
    var status: String
    
    init(name: String, status: String) {
        self.name = name
        self.status = status
    }
}

class Host: ObservableObject, Identifiable {
    var name: String
    var status: String
    var device: String
    
    init(name: String, status: String, device: String) {
        self.name = name
        self.status = status
        self.device = device
    }
}

struct CreateSessionView: View {
    @EnvironmentObject var manager: MultipeerManager
    @EnvironmentObject var hostState: GameState
    @EnvironmentObject var pool: MessagePool
    
    @Binding var currentScreen: GameScreen
    
    var count: Int = 0
    
    var players: [(peer: Peer, status: GameState.PeerStatus)] {
        hostState.shared.players.map {
            (peer: $0.key, status: $0.value)
        }
    }
    
    var host =  Host(name: "George", status: "Ready", device: "iPhone Name 1")
    
    @State private var gameModeNormal = "Normal"
    var gamemodes = ["Normal", "Hard"]
    
    var allPlayersReady: Bool {
        players.count > 0 && players.allSatisfy { (_, status) in
            status == .Ready
        }
    }
    
    var remainingSpace: Int {
        5 - players.filter({ $0.status == .Ready }).count
    }
    
    var body: some View {
        VStack {
            HStack (spacing: 40) {
                Text("Players")
                    .font(.custom("Futura Medium", size: 20))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(remainingSpace) spaces remaining")
                    .font(.custom("Futura Medium", size: 17))
                    .foregroundColor(.white)
                    .opacity(0.7)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundColor(.white)
            }
            .frame(width: 350)
            .padding(.top, 50)

            ScrollView {
                HStack (alignment: .bottom){
                    Text(manager.data.name)
                        .foregroundColor(.white)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                    
                    
                    Spacer()
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                        .padding(.trailing, 10)
                    
                }
                .frame(minHeight: 40)
                .padding(.top)
                
                Divider()
                    .background(.white)
                
                ForEach(players, id: \.peer) { (player, status) in
                    HStack(alignment: .center) {
                        Text(hostState.shared.names[player] ?? "N/A")
                            .foregroundColor(.white)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 10)
                        
                        Text(status.description)
                            .foregroundColor(.white)
                            .opacity(0.8)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        ZStack {
                            Circle()
                                .stroke(.white, lineWidth: 1)
                                .opacity(0.8)
                                .frame(width: 15, height: 15)
                            Button(action: {
                                // reject request
                            }) {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.white)
                                    .opacity(0.8)
                                    .frame(width: 7, height: 7)
                            }
                        }
                        .padding(.trailing, 15)
                        
                    }
                    .frame(minHeight: 40)
                    
                    Divider()
                        .background(.white)
                    
                }
                Spacer()
            }
            .scrollIndicators(.hidden)
            .background(
                Color(red: 190/255, green: 190/255, blue: 190/255, opacity: 0.3)
                    .cornerRadius(10)
            )
            .frame(height: 300)
            
            Text("Discoverable nearby as \"\(manager.data.name)\" ")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
                .frame(height: 80)
            
            VStack (alignment: .center, spacing: 0){
                Text("Game Mode")
                    .font(.custom("Futura Medium", size: 20))
                    .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                Picker("What gamemode?", selection: $gameModeNormal) {
                    ForEach(gamemodes, id: \.self) {
                        Text($0).foregroundColor(.white)
                    }
                }
                .pickerStyle(.segmented)
                .background(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.15000000596046448)))
                .cornerRadius(10, corners: .allCorners)
            }
            
            Spacer()
            
            HStack {
                Button(action: {
                    print("Cancel")
                    hostState.myCurrentScreen = .initial
                    currentScreen = .initial
                }, label: {
                    Text("Cancel")
                        .foregroundColor(.white)
                        .bold()
                })
                .frame(maxWidth: .infinity)
                
                
                Button(action: {
                    self.startGame()
                }, label: {
                    Text("Start Game")
                        .foregroundColor(!allPlayersReady ? .gray : .white)
                        .bold()
                })
                .frame(maxWidth: .infinity)
                .background(
                    ButtonBackground()
                        .opacity(allPlayersReady ? 1.0 : 0.1)
                )
                .disabled(!allPlayersReady)
            }
            .padding(.bottom)
        }
        .padding(.horizontal)
        .foregroundColor(.white)
        .font(.custom("Futura Medium", size: 17))
    }
    
    /// This will change the current screen for everyone to player order,
    /// including the host.
    func startGame() {
        hostState.startCounter(timerDuration: 5)
        hostState.sync { state in
            for peer in state.currentScreen.keys {
                state.currentScreen[peer] = .playerOrder
            }
        }
    }
}
