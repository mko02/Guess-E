//
//  ContentView.swift
//  guesse_landing
//
//  Created by Lauren Pak on 3/30/23.
//

import SwiftUI

struct LandingPage: View {
    @Binding var screen: GameScreen
    @Binding var name: String
    @EnvironmentObject var manager: MultipeerManager
    
    var body: some View {
        VStack {
            ZStack {
                Image("filledRotatedRec")
                Image("filledRegularRec")
            }
            .offset(x: -160, y: 44)
            ZStack {
                Image("Rectangle_14")
                Image("rotatedRectangle")
            }
            .offset(x: -160, y: 48)
            HStack {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 4, height: 610)
                    .padding(.trailing, 5)
                VStack(spacing: 8) {
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Text("GUESS-E")
                        .foregroundColor(.white)
                        .font(.custom("Futura", size: 45)).bold()
                        .padding(.trailing, 110)
                    ZStack(alignment: .leading){
                        if name.isEmpty {
                            Text("Name").foregroundColor(.white)
                                .padding(.leading, 10)
                                .font(.custom("Futura", size: 15))
                        }
                        TextField("", text: $name)
                            .textFieldStyle(.plain)
                            .foregroundColor(.white)
                            .tint(.white)
                            .frame(width: 295, height: 32)
                            .opacity(name.isEmpty ? 0.5 : 1)
                            .padding(.leading, 9)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                        
                        
                    }
                    /*TextField("Name", text: $inputText)
                     .font(.custom("Futura", size: 15))
                     .accentColor(.white)
                     .frame(width: 295, height: 32).opacity(inputText.isEmpty ? 0.5 : 1)
                     .padding(.leading, 9)
                     .background(Color.gray.opacity(0.3))
                     .cornerRadius(8)*/
                    
                    HStack {
                        Button(action: {
                            screen = .createGame
                            manager.hostState.myCurrentScreen = .createGame
                        }, label: {
                            Text("Create Game")
                                .foregroundColor(.white.opacity(name.isEmpty ? 0.3 : 1))
                                .font(.custom("Futura", size: 16))
                                .padding(.horizontal, 25)
                                .padding(.vertical, 13)
                                .background(Color.gray.opacity(name.isEmpty ? 0.2 : 0.30))
                                .cornerRadius(8)
                        })
                        Button(action: {
                            screen = .joinGame
                        }, label: {
                            Text("Join Game")
                                .font(.custom("Futura", size: 16))
                                .foregroundColor(.white.opacity(name.isEmpty ? 0.3 : 1))
                                .padding(.vertical, 13)
                                .padding(.horizontal, 34)
                                .background(Color.gray.opacity(name.isEmpty ? 0.2 : 0.30))
                                .cornerRadius(8)
                        })
                    }
                    .disabled(name.isEmpty)
                    ZStack {
                        Image("Rectangle_14")
                        Image("rotatedRectangle")
                    }
                    .offset(x: -168, y: 96)
                    ZStack {
                        Image("filledRotatedRec")
                        Image("filledRegularRec")
                    }
                    .offset(x: -168, y: 99)
                    Spacer()
                }
            }
        }
    }
}
