//
//  RankingResultsView.swift
//  Guess-E
//
//  Created by Nicholas Candello on 4/6/23.
//

import SwiftUI

struct RankingResultsView: View {
    @State private var status: String = ""
    @EnvironmentObject var state: GameState
    @EnvironmentObject var manager: MultipeerManager
    
    var dropFirstProjection: Binding<
        some RandomAccessCollection<Guess> & MutableCollection<Guess>
    > {
        Binding {
            state.shared.gueses.dropFirst()
        } set: { newGuesses in
            guard !newGuesses.isEmpty else { return }
            
            // replace the results
            state.shared.gueses.replaceSubrange(1..., with: newGuesses)
        }
    }
        
    var hostName: String {
        guard let host = state.host else { return "N/A" }
        return manager.hostNames[host] ?? manager.data.name
    }
    
    var body: some View {
        VStack {
                //Image Section
            GuessImage {
                if let firstGuess = state.shared.gueses.first {
                    VStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: 3) {
                            Spacer()
                            Text("#1. ")
                                .font(.custom("Futura", size: 17)) +
                            Text("\(state.shared.names[firstGuess.peer] ?? "N/A")")
                                .font(.custom("Futura", size: 20).bold())
                            Text("\"\(firstGuess.message)\"")
                                .font(.custom("Futura", size: 17))
                                .bold()
                        }
                        .padding()
                        .foregroundColor(.white)
                    }
                }
            }
                
            GuessList(
                guesses: dropFirstProjection,
                cellType: RankedGuessListCell.self,
                footer: {
                    Text("\(hostName) originally asked: \"\(state.shared.prompt ?? "N/A")\"")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color.white.opacity(0.5))
                        .font(.custom("Futura", size: 14))
                        .padding(.horizontal)
                }
            )
            
            Button("Prepare for Round 2") {
                
            }
            .buttonStyle(GuessEButtonStyle())
            
        }
        .ignoresSafeArea(edges: [.top])
    }
}

protocol GuessListCell: View {
    init(idx: Int, guess: Guess)
}

struct RegularGuessListCell: GuessListCell {
    let idx: Int
    let guess: Guess
    
    var body: some View {
        VStack {
            Text(guess.message)
                .foregroundColor(Color(hex: "#848488"))
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        .cornerRadius(10)
    }
}

struct RankedGuessListCell: GuessListCell {
    @EnvironmentObject var state: GameState
    let idx: Int
    let guess: Guess
    
    init(idx: Int, guess: Guess) {
        self.idx = idx
        self.guess = guess
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("#\(idx + 2)")
                .font(.custom("Futura", size: 17)) +
            Text(" \(state.shared.names[guess.peer] ?? "N/A")")
                .font(.custom("Futura", size: 20).bold())
            
            Text("\"\(guess.message)\"")
                .font(.custom("Futura", size: 17))
                .multilineTextAlignment(.leading)
                
        }
        .foregroundColor(Color(hex: "#464646"))
        .padding(.horizontal)
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        .cornerRadius(10)

    }
}

struct RankingResultsView_Previews: PreviewProvider {
    static var previews: some View {
        RankingGuessesView()
    }
}
