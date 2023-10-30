//
//  ContentView.swift
//  JoinSessionView
//
//  Created by Nicholas Candello on 3/30/23.
//

import SwiftUI


struct JoinSessionView: View {
    @EnvironmentObject var manager: MultipeerManager
    @EnvironmentObject var pool: MessagePool
    
    @State private var selectedHost: Peer? = nil
    @Binding var currentScreen: GameScreen
    @Binding var joinedGame: GameState?
    
    var body: some View {
        VStack {
            VStack(spacing: 2) {

                Text("Join a Local Session")
                    .bold()
                    .frame(width: 340, alignment: .leading)
                    .foregroundColor(.white)
                    .font(.custom("Futura Medium", size: 20))
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        ForEach(Array(manager.hosts.keys), id: \.id) { host in
                            Button {
                                self.selectedHost = host
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(manager.hostNames[host] ?? "N/A")
                                    }
                                    Spacer()
                                    Image(systemName: "person.fill")
                                    
                                    Text("\(readyPlayerCount(for: host) + 1)")
                                }
                                .foregroundColor(
                                    selectedHost == host ? Color.black : Color.white
                                )
                                .padding(10)
                                .background(
                                    selectedHost == host ? Color(red: 1, green: 1, blue: 1, opacity: 0.68) : Color.clear
                                )
                                .cornerRadius(10)
                            }
                            .frame(minHeight: 56)
                        }
                    }
                    .font(.custom("Futura Medium", size: 17))
                    .padding()
                }
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .background(Color(red: 190/255, green: 190/255, blue: 190/255, opacity: 0.3))
                .cornerRadius(20)
                
                
                Spacer()
                //2 Buttons
                HStack {
                    //2 Buttons
                        //"Back" button
                    Button {
                        currentScreen = .initial
                    } label: {
                        Text("Back")
                            .foregroundColor(Color.white)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    
                    //"Join Game" button
                    Button {
                        if let selectedHost {
                            pool.send(
                                message: JoinGame(name: manager.data.name),
                                to: selectedHost
                            )
                            
                            joinedGame = manager.hosts[selectedHost]
                            joinedGame?.host = selectedHost
                        }
                    } label: {
                        Text("Join Game")
                            .foregroundColor(selectedHost == nil ? .gray : .white)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        ButtonBackground()
                            .opacity(selectedHost == nil ? 0.1 : 1)
                    )
                    .disabled(selectedHost == nil)
                }
                .font(.custom("Futura Medium", size: 17))
            }
            .padding()
        }
    }
                    
    func readyPlayerCount(for host: Peer) -> Int {
        guard let hostState = manager.hosts[host] else { return 0 }
        return hostState.shared.players.reduce(0) { res, tuple in
            let (_, status) = tuple
            return res + (status == .Ready ? 1 : 0)
        }
    }

}
