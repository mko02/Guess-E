//
//  ImageCreatorView.swift
//  Guess-E
//
//  Created by Mathew Seng on 3/30/23.
//

import Foundation
import SwiftUI
import OpenAISwift

struct ImageCreatorView: View {
    @EnvironmentObject var state: GameState
    @State var promptText = ""
    @State var characterCount = 0
    
    @EnvironmentObject var manager: MultipeerManager
    @EnvironmentObject var pool: MessagePool
    @EnvironmentObject var openAI: OpenAISwift
    
    @State private var loadingImage: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height:111)
            
                Text("What should I draw?")
                    .foregroundColor(.white)
                    .font(.custom("Futura Medium", size: 24))
                    .bold()
                    .multilineTextAlignment(.leading)
                .padding()
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 190/255, green: 190/255, blue: 190/255, opacity: 0.3))
                if(promptText.isEmpty){
                    Text("Enter Prompt...")
                        .foregroundColor(.white)
                        .opacity(0.7)
                        .padding(EdgeInsets(top: 7, leading: 7, bottom: 0, trailing: 7))
                }
                TextField("", text: $promptText, axis: .vertical)
//                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .tint(.white)
                    .lineLimit(5, reservesSpace: true)
                    .cornerRadius(8)
                    .padding(EdgeInsets(top: 7, leading: 7, bottom: 0, trailing: 7))
                    .onChange(of: promptText) { newValue in
                        if newValue.count > 100 {
                            promptText = String(newValue.prefix(100))
                        }
                        characterCount = newValue.count
                    }
            }
                .frame(height: 120)
                .padding()
                
                Spacer().frame(height: 0)
                
            HStack() {
                Text("\(characterCount)/100")
                    .foregroundColor(.init(hex: "C0FFFFFF"))
                    .padding(.horizontal)
                    .multilineTextAlignment(.leading)

                Spacer()

                Button(action: {
                    self.promptText = "Fish eating a snowcone in the style of Van Goh"
                    self.characterCount = promptText.count
                }) {
                    Text("No Idea")
                        .foregroundColor(.white)
                        .font(.custom("Futura Medium", size: 17))
                        .multilineTextAlignment(.trailing)
                }
            
                .frame(width: 90)
                .padding(.horizontal)
            }
            
            Spacer()
            Button {
                self.loadingImage = true
                self.state.endCounter()
                
                let promt = promptText
                openAI.sendImages(with: promt, size: .size512) { result in
                    switch result {
                    case .success(let success):
                        guard let url = success.data?.first?.url else { return }
                        DispatchQueue.main.async {
                            self.loadingImage = false
                            self.state.sync { shared in
                                shared.prompt = promt
                                shared.imageURL = URL(string: url)
                            }
                            self.state.moveToNextScreen()
                        }
                    case .failure(let failure):
                        print(failure.localizedDescription)
                    }
                }
            } label: {
                if loadingImage {
                    ProgressView()
                } else {
                    Text("Generate")
                }
            }
            .buttonStyle(GuessEButtonStyle())
        }
        .font(.custom("Futura Medium", size: 17))
    }
}

struct ImageCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        ImageCreatorView()
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

