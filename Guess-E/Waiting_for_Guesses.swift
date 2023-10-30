//
//  waiting for guesses.swift
//  Guess-E
//
//  Created by Liam Dolphin on 4/6/23.
//
import SwiftUI

struct Waiting_for_Guesses: View {
    private let blurRadius: CGFloat = 40
    @State private var comment: String = getFact()
    
    @EnvironmentObject var state: GameState
    @EnvironmentObject var manager: MultipeerManager
    @EnvironmentObject var pool: MessagePool
    

    var title: String {
        let allPlayers = Set(state.shared.players.map(\.key))
        let madeGuessPlayers = Set(state.shared.gueses.map(\.peer))
        let waitingOn = allPlayers.subtracting(madeGuessPlayers)
        let names = waitingOn
            .sorted(by: { $0.id < $1.id})
            .compactMap { state.shared.names[$0] }
        
        return "Waiting on " +  names.joined(separator: ", ")
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
            Button {
                
            } label: {
                Text(title)
                    .padding(.horizontal)
                    .lineLimit(1)
            }
            .buttonStyle(GuessEButtonStyle())
        }
        .padding()
        .font(.custom("Futura Medium", size: 17))
    }
}

struct Waiting_for_Guesses_Previews: PreviewProvider {
    static var previews: some View {
        Waiting_for_Guesses()
    }
}

