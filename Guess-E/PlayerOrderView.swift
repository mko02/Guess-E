//
//  PlayerOrderView.swift
//  Guess-E
//
//  Created by Noah Sadir on 3/30/23.
//

import SwiftUI

struct PlayerOrderView: View {
    
    @EnvironmentObject var manager: MultipeerManager
    @EnvironmentObject var pool: MessagePool
    @EnvironmentObject var state: GameState
    
    var hostName: String {
        guard let host = state.host else { return "N/A" }
        return manager.hostNames[host] ?? manager.data.name
    }
    
    var players: [String] {
        Array(state.shared.names.values)
    }
    
    var body: some View {
        VStack (alignment: .leading){
            Spacer()
            VStack(alignment: .leading) {
                Text("Our first victim is")
                    .font(.custom("Futura Medium", size: 24))
                    .foregroundColor(.white)
                    .fontWeight(.heavy)
                
                Text(hostName)
                    .font(.custom("Futura Medium", size: 50))
                    .foregroundColor(.white)
                    .layoutPriority(1) // this should take priority in the event of a space conflict
                
                ForEach(players, id: \.self) { player in
                    Text(player)
                        .font(.custom("Futura Medium", size: 24))
                        .foregroundColor(.init(hex: "C0FFFFFF"))
                        .layoutPriority(0)
                }
            }
            .frame(maxHeight: 48) // should equal largest font size
            
            .fontWeight(.bold)
            Spacer()
            Spacer()
            Button("Starting Soon") {
                
            }
            .buttonStyle(GuessEButtonStyle())
        }
        .padding()
    }
}

/**
 Custom progress bar which follows Guess-E style guidelines
 
 Adapted from:
 https://stackoverflow.com/questions/68755577/swiftui-view-with-different-widths-with-fill-depending-on-the-percentage
 */
struct InterstitialProgressBar: View {
    var tint: Color = Color(red: 91/255, green: 170/255, blue: 255/255)
    @EnvironmentObject var state: GameState
    
    var body: some View {
        HStack {
            Text("Starting Soon")
                .bold()
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            ButtonBackground()
                            ButtonBackground()
                                .frame(width: geometry.size.width * calcPercent(), height: geometry.size.height)
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white, lineWidth: 3)
                            HStack {
                                Text(calcTimeLeftString())
                                    .padding(.leading)
                                    .bold()
                                Spacer()
                            }
                        }
                    }.clipShape(RoundedRectangle(cornerRadius: 10))
                )
        }
        .foregroundColor(.white)
        .font(.custom("Futura Medium", size: 17))
    }
    func calcPercent() -> Double {
        return Double((state.counter.timeElapsed!))/Double((state.counter.totalTime!))
    }
    
    func calcTimeLeftString() -> String {
        return "\((state.counter.totalTime ?? 20) - (state.counter.timeElapsed ?? 0))s"
    }
}

struct PlayerOrderView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerOrderView()
    }
}
