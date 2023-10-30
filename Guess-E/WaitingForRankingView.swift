//
//  WaitingForRankingView.swift
//  Guess-E
//
//  Created by Nicholas Candello on 4/5/23.
//

import SwiftUI

struct WaitingForRankingView: View {
    @EnvironmentObject var manager: MultipeerManager
    @EnvironmentObject var state: GameState
    
    var myGuess: Guess? {
        state.shared.gueses.first(where: { $0.peer == manager.myPeer })
    }
    
    var otherGuesses: Binding<[Guess]> {
        let guesses = state.shared.gueses.filter {
            $0 != myGuess
        }
        return .constant(guesses)
    }
    
    var body: some View {
        VStack {
            GuessImage {
                VStack(alignment: .leading, spacing: 3) {
                    Text("You")
                        .font(.custom("Futura Medium", size: 17))
                        .bold()
                    Text("\"\(myGuess?.message ?? "N/A")\"")
                }
                .padding()
                .font(.custom("Futura Medium", size: 17))
                .foregroundColor(.white)
            }

            //"They Guessed" Section
            GuessList(
                title: "People Guessed",
                guesses: otherGuesses,
                cellType: RegularGuessListCell.self
            )
            
            Spacer()
            
            Button(state.hostName ?? "N/A") {
                
            }
            .buttonStyle(GuessEButtonStyle())
            
        }
        .ignoresSafeArea(edges: [.top])
    }
}
