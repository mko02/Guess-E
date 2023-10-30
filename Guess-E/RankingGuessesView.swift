//
//  RankingGuessesView.swift
//  Guess-E
//
//  Created by Nicholas Candello on 4/4/23.
//

import SwiftUI
import MultipeerConnectivity

struct Guess: Identifiable, Hashable, Codable {
    let peer: Peer
    var message: String
    
    var id: String {
        message
    }
    
    init(peer: Peer, message: String) {
        self.peer = peer
        self.message = message
    }
}


struct RankingGuessesView: View {
    @EnvironmentObject var game: GameState
    @EnvironmentObject var manager: MultipeerManager
    @EnvironmentObject var pool: MessagePool

   
    @State private var timeLeft = 20
    @State private var timeElapsedAnimation = 0
    
    var body: some View {
        VStack {
            //Image Section
            
            GuessImage {
                VStack(alignment: .leading, spacing: 3) {
                    Text("You")
                        .font(.custom("Futura Medium", size: 17))
                        .bold()
                    Text("\"\(game.shared.prompt ?? "N/A")\"")
                }
                .padding()
                .font(.custom("Futura Medium", size: 17))
                .foregroundColor(.white)
            }
            
            //"They Guessed" Section
            GuessList(
                title: "Rank Their Guesses:",
                editMode: .active,
                guesses: $game.shared.gueses,
                cellType: RegularGuessListCell.self
            )
            
            Spacer()
            
            //Button
            Button("Done") {
                game.endCounter()
                game.startCounter(timerDuration: 30)
                game.sync { shared in
                    for peer in shared.currentScreen.keys {
                        shared.currentScreen[peer] = .rankingResults
                    }
                }
            }
            .buttonStyle(GuessEButtonStyle())
        }
        .font(.custom("Futura Medium", size: 17))
        .ignoresSafeArea(edges: [.top])
    }
    
    func move(from source: IndexSet, to destination: Int) {
        game.sync { shared in
            shared.gueses.move(fromOffsets: source, toOffset: destination)
        }
    }
}



struct RankingGuessesView_Previews:
    PreviewProvider {
    static var previews: some View {
        RankingGuessesView()
            .environmentObject(GameState(pool: .init(session: .init())))
            .environmentObject(MultipeerManager.shared)
            .environmentObject(MultipeerManager.shared.pool)
    }
}


struct GuessList<
    Cell: GuessListCell, Guesses: RandomAccessCollection<Guess>, Footer: View
>: View where Guesses: MutableCollection {
    
    @EnvironmentObject private var state: GameState
    
    let title: String?
    let editMode: Binding<EditMode>
    let guesses: Binding<Guesses>

    let footer: Footer
    
    init(
        title: String? = nil,
        editMode: EditMode = .inactive,
        guesses: Binding<Guesses>,
        cellType: Cell.Type,
        @ViewBuilder footer: () -> Footer = { EmptyView() }
    ) {
        self.guesses = guesses
        self.title = title
        self.editMode = .constant(editMode)
        self.footer = footer()
    }
    
    var enumerated: [(idx: Int, guess: Binding<Guess>)] {
        guesses.enumerated().map {
            (idx: $0.offset, guess: $0.element)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if !enumerated.isEmpty {
                if let title {
                    Text(title)
                        .font(.custom("Futura Bold", size:20))
                        .foregroundColor(.white)
                }
                
                List {
                    ForEach(enumerated, id: \.guess.id) { (idx, $guess) in
                        Cell(idx: idx, guess: guess)
                    }
                    .onMove(perform: move)
                    .listRowBackground(
                        Color.white
                            .opacity(0.68)
                            .cornerRadius(10)
                            .padding(10)
                    )
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .environment(\.editMode, editMode)
                .background(.ultraThinMaterial)
                .scrollContentBackground(.hidden)
                .cornerRadius(10)
                
                footer
            } else {
                Spacer()
            }
        }
        .padding()
        .padding(.top, 16)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        state.sync { shared in
            shared.gueses.move(fromOffsets: source, toOffset: destination)
        }
    }

}

struct GuessImage<Content: View>: View {
    @EnvironmentObject var state: GameState
    let textSection: Content
    
    init(@ViewBuilder textSection: () -> Content) {
        self.textSection = textSection()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(
                url: state.shared.imageURL,
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                },
                placeholder: {
                    ProgressView()
                }
            )
            
            textSection
                .padding(.top, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [.clear, .black],
                        startPoint: .top, endPoint: .bottom
                    )
                )
        }
        .cornerRadius(10)
        .frame(height: 394)
    }
}

struct GuessEButtonStyle: ButtonStyle {
    var tint: Color = Color(red: 91/255, green: 170/255, blue: 255/255)
    @EnvironmentObject var state: GameState

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .lineLimit(1)
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
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                )
        }
        .foregroundColor(.white)
        .font(.custom("Futura Medium", size: 17))
        .padding(.horizontal)
    }
    
    func calcPercent() -> Double {
        guard let timeElapsed = state.counter.timeElapsed,
              let totalTime = state.counter.totalTime
        else { return 1.0 }
        
        return Double(timeElapsed) / Double(totalTime)
    }
    
    func calcTimeLeftString() -> String {
        if state.counter.timerEnabled {
            return "\((state.counter.totalTime ?? 20) - (state.counter.timeElapsed ?? 0))s"
        }
        
        return "🔥"
    }

}
