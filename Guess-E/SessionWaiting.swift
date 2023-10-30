//
//  ContentView.swift
//  Guess-E
//
//  Created by Maksim Tochilkin on 3/30/23.
//

import SwiftUI

struct SessionWaiting: View {
    @EnvironmentObject var manager: MultipeerManager
    @EnvironmentObject var state: GameState
    @EnvironmentObject var pool: MessagePool
    
    var players: [(peer: Peer, status: GameState.PeerStatus)] {
        state.shared.players.map {
            (peer: $0.key, status: $0.value)
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
                .foregroundColor(Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.31))
            }
            .frame(width: 350)
            .padding(.top, 50)
            
            ScrollView {
                HStack (alignment: .bottom) {
                    Text(state.hostName ?? "N/A")
                        .foregroundColor(.white)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                    
                    Spacer()
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                }
                .frame(minHeight: 40)
                
                Divider()
                    .frame(height: 1)
                    .background(.white)
                
                ForEach(players, id: \.peer) { (player, status) in
                    HStack(alignment: .center) {
                        Text(state.shared.names[player] ?? "N/A")
                            .foregroundColor(.white)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 10)
                        
                        Text(status.description)
                            .foregroundColor(.white)
                            .opacity(0.8)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 10)
                        
                    }
                    .frame(minHeight: 40)
                    
                    Divider()
                        .frame(height: 1)
                        .background(.white)
                    
                }
                Spacer()
            }
            .scrollIndicators(.hidden)
            .frame(height: 200)
            .padding(4)
            .background(
                Color(red: 190/255, green: 190/255, blue: 190/255, opacity: 0.3)
                .cornerRadius(10)
            )
            
            
            Spacer()
            
            HStack {
                
                Button(action: {
                    // handle text click here
                }, label: {
                    Text("Leave")
                        .foregroundColor(.white)
                        .bold()
                })
                .frame(maxWidth: .infinity)
                
                
                Button(action: {
                    state.setPlayerReady()
                }, label: {
                    ZStack{
                        ButtonBackground()
                        Text("Ready")
                            .foregroundColor(.white)
                            .bold()
                    }
                })
                .background(.clear)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
//                .padding(.bottom, 20)
        }
        .foregroundColor(.white)
        .padding()
        .font(.custom("Futura Medium", size: 17))
    }
}

struct SessionWaiting_Previews: PreviewProvider {
    static var previews: some View {
        SessionWaiting()
    }
}
