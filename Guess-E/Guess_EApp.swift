//
//  Guess_EApp.swift
//  Guess-E
//
//  Created by Maksim Tochilkin on 3/30/23.
//

import SwiftUI
import OpenAISwift

enum GameScreen: Codable {
    case initial, createGame, joinGame, waitRoom, playerOrder,
         imageCreator, waitingForImage, waitingForRanking,
         waitingForGuesses, guessingImage, rankingGuesses,
         rankingResults
}

private let transitionDuration: Double = 0.4

struct HostScreenSwitch: View {
    @EnvironmentObject var state: GameState
    @EnvironmentObject var manager: MultipeerManager
    @Binding var currentScreen: GameScreen
    
    var body: some View {
        switch state.myCurrentScreen {
        case .createGame:
            CreateSessionView(currentScreen: $currentScreen)
                .environmentObject(manager.hostState)
                .onAppear {
                    manager.startBrowsing()
                }
                .onDisappear {
                    manager.stopBrowsing()
                }
                .transition(
                    .opacity.animation(.linear(duration: transitionDuration))
                )
        case .playerOrder:
            PlayerOrderView()
                .transition(
                    .opacity.animation(.linear(duration: transitionDuration))
                )
        case .imageCreator:
            ImageCreatorView()
                .environmentObject(manager.hostState)
                .transition(
                    .opacity.animation(.linear(duration: transitionDuration))
                )
        case .waitingForGuesses:
            Waiting_for_Guesses()
            .environmentObject(manager.hostState)
            .transition(
                .opacity.animation(.linear(duration: transitionDuration))
            )
        case .rankingGuesses:
            RankingGuessesView()
                .environmentObject(manager.hostState)
                .transition(
                    .opacity.animation(.linear(duration: transitionDuration))
                )
        case .rankingResults:
            RankingResultsView()
                .transition(
                    .opacity.animation(.linear(duration: transitionDuration))
                )
            
        default:
            Color.red // other views are not part of the host screen flow
        }
    }
}

struct PlayerScreenFlow: View {
    @EnvironmentObject var manager: MultipeerManager
    @EnvironmentObject var state: GameState
    
    var body: some View {
        switch state.myCurrentScreen {
        case .waitRoom:
            SessionWaiting()
                .transition(
                    .opacity.animation(.linear(duration: transitionDuration))
                )
        case .playerOrder:
            PlayerOrderView()
                .transition(
                    .opacity.animation(.linear(duration: transitionDuration))
                )
        case .waitingForImage:
            WaitingForImageView()
                .transition(
                    .opacity.animation(.linear(duration: transitionDuration))
                )
        case .waitingForRanking:
            WaitingForRankingView()
                .transition(
                    .opacity.animation(.linear(duration: transitionDuration))
                )
        case .guessingImage:
            GuessingImageView()
                .transition(
                    .opacity.animation(.linear(duration: transitionDuration))
                )
        case .rankingResults:
            RankingResultsView()
                .transition(
                    .opacity.animation(.linear(duration: transitionDuration))
                )
            
        default:
            Color.red // other screens are not part of the player screen flow
        }
    }
}

struct PlayerScreenSwitch: View {
    @EnvironmentObject var manager: MultipeerManager
    @Binding var currentScreen: GameScreen
    @State private var joinedGame: GameState? = nil
    
    var body: some View {
        if let joinedGame {
            PlayerScreenFlow()
                .environmentObject(joinedGame)
        } else {
            JoinSessionView(
                currentScreen: $currentScreen, joinedGame: $joinedGame
            )
            .onAppear {
                manager.startAdvertising()
            }
            .onDisappear {
                manager.stopAdvertising()
            }
            .transition(
                .opacity.animation(.linear(duration: transitionDuration))
            )
        }
    }
}

struct InitialScreens: View {
    @EnvironmentObject var manager: MultipeerManager
    @State private var screen: GameScreen = .initial
    
    var body: some View {
        ZStack {
            Background()
            
            if screen == .initial {
                LandingPage(screen: $screen, name: $manager.data.name)
                    .transition(
                        .opacity.animation(.linear(duration: transitionDuration))
                    )
            }
            
            if screen == .createGame {
                // TODO: add timer
                HostScreenSwitch(currentScreen: $screen)
                    .environmentObject(manager.hostState)
                    .transition(
                        .opacity.animation(.linear(duration: transitionDuration))
                    )
                    .onReceive(
                        manager.hostState.activeTimer
                            .receive(on: DispatchQueue.main)
                    ) { timer in
                        manager.hostState.updateTimer()
                        print("updated timer... Timer enabled: \(manager.hostState.counter.timerEnabled)")
                    }

            }
            
            if screen == .joinGame {
                PlayerScreenSwitch(currentScreen: $screen)
                    .transition(
                        .opacity.animation(.linear(duration: transitionDuration))
                    )
            }
        }
    }
}

extension OpenAISwift: ObservableObject {

}

private func getCSVData() -> Array<String> {
    do {
        let path = Bundle.main.path(forResource: "Facts", ofType: "csv") // file path for file "data.txt"
        let content = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        let lines = content.split(separator: "\n")
        let parsedCSV = lines.map { String($0) }
        return parsedCSV
    }
    catch {
        return []
    }
}

func getFact() -> String {
    let facts = getCSVData()
    let min = 0
    let max = (facts.count - 1)
    let randomNumber = Int(arc4random_uniform(UInt32(max - min + 1))) + min
    return facts[randomNumber]
}

@main
struct Guess_EApp: App {
    @State private var screen: GameScreen = .initial
    @StateObject private var manager: MultipeerManager = .shared
    @StateObject private var openAI: OpenAISwift = OpenAISwift(
        authToken: ""
    )
    var body: some Scene {
        WindowGroup {
            InitialScreens()
                .environmentObject(manager)
                .environmentObject(manager.pool)
                .environmentObject(openAI)
        }
    }
}
