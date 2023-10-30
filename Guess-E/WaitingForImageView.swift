//
//  WaitingForImageView.swift
//  Guess-E
//
//  Created by Gabe McGuire on 3/30/23.
//

import SwiftUI

struct WaitingForImageView: View {
    private let blurRadius: CGFloat = 40
    @State private var comment: String = getFact()
    
    @EnvironmentObject var state: GameState
    @EnvironmentObject var manager: MultipeerManager
    @EnvironmentObject var pool: MessagePool
    

    var hostName: String {
        guard let host = state.host else { return "N/A" }
        return manager.hostNames[host] ?? "N/A"
    }
    
    var body: some View {
            //Image and text
        VStack (spacing: 54) {
            Image(systemName: "brain.head.profile")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height:245)
                .foregroundColor(.white)
                .padding()
            ZStack (alignment: .topLeading){
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.20000000298023224)))
                Text(comment)
                    .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.76)))
                    .frame(width: 330, alignment: .topLeading)
                    .padding()
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            
            //Timer bar
            Button("Waiting on \(hostName)") {
                
            }
            .buttonStyle(GuessEButtonStyle())
        }
        .padding()
        .font(.custom("Futura Medium", size: 17))
    }
}
