//
//  GuessingImageView.swift
//  Guess-E
//
//  Created by Alena Tochilkina on 30.03.2023.
//

import SwiftUI

struct ButtonTimer: View {
    @State private var editMode = EditMode.active
    @State private var timeLeft = 20
    @State private var timeElapsedAnimation = 0
    @Binding var userGuess: String
    @EnvironmentObject var pool: MessagePool
    @EnvironmentObject var state: GameState
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
            Button {
                if let host = state.host {
                    pool.send(message: UserGuess(guess: userGuess), to: host)
                }
            } label: {
                ZStack(alignment: .leading) {
                    //Background
                    ButtonBackground()
                    //Timer Bar
                    ButtonBackground()
                        .frame(width: CGFloat(timeElapsedAnimation), height: 48, alignment: .leading)
                        .onReceive(timer) { firedDate in
                            timeElapsedAnimation += 343/20
                                    }
                   
                    Text("\(timeLeft)s")
                        .multilineTextAlignment(.leading)
                        .padding()
                        .onReceive(timer) { input in
                            if self.timeLeft > 0 {
                                self.timeLeft -= 1
                            } else {
                                timer.upstream.connect().cancel()
                                self.editMode = .inactive
                            }
                        }
                    Text("Done")
                        .padding()
                        .background(.clear)
                        .frame(maxWidth: .infinity, alignment: .center)
                
            }
            .frame(width: 343, height: 48)
            .bold()
            .foregroundColor(.white)
            .cornerRadius(6)
            .padding()
                
            }
        }
    
}

struct ImageOverlay: View {
    @FocusState private var focusedField: Bool
    @Binding var userGuess: String
    @State var currentCount: Int = 0;
    var limit: Int = 100;
    var userGuessBinding: Binding<String> {
        Binding {
            userGuess
        } set: { newValue in
            if(newValue.count <= limit){
                userGuess = newValue
                currentCount = newValue.count
            }
        }
    }
    
    
    var body: some View {
        GuessImage {
            VStack(spacing: 5) {
                ZStack(alignment: .leading){
                    if(userGuess.isEmpty){
                        Text("This looks like...").foregroundColor(.white)
                    }
                    TextField("", text: userGuessBinding, axis: .vertical)
                        .lineLimit(3)
                        .textFieldStyle(.plain)
                        .foregroundColor(.white)
                        .tint(.white)
                        .focused($focusedField)
                        .onChange(of: userGuess) { newValue in
                            guard let newValueLastChar = newValue.last else { return }
                            if newValueLastChar == "\n" {
                                userGuess.removeLast()
                                focusedField = false
                            }
                        }
                }
                Text("\(currentCount) / \(limit)")
                    .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                    .foregroundColor(.white)
            }
            .font(.custom("Futura Medium",size: 17))
            .padding()
        }
    }
}

struct GuessingImageView: View {
    let imageName = "ai_example_art"
    @State private var userGuess: String = ""
    @EnvironmentObject var pool: MessagePool
    @EnvironmentObject var state: GameState

    var body: some View {
        VStack{
            ImageOverlay(userGuess: $userGuess)

            Spacer()
            
            Button("Send my guess") {
                if let host = state.host {
                    pool.send(message: UserGuess(guess: userGuess), to: host)
                }
            }
            .buttonStyle(GuessEButtonStyle())
            .padding(.bottom)
        }
        .ignoresSafeArea(edges: [.top])

    }
}

struct GuessingImageView_Previews: PreviewProvider {
    static var previews: some View {
        GuessingImageView()
    }
}
