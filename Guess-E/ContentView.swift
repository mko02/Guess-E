//
//  ContentView.swift
//  Guess-E
//
//  Created by Maksim Tochilkin on 3/30/23.
//  

import SwiftUI

//Global Background Style
struct Background: View {
    @State private var circle1X = -150
    @State private var circle1Y = -350
    @State private var circle2X = 150
    @State private var circle2Y = -55
    @State private var circle3X = -100
    @State private var circle3Y = 300
    var body: some View {
        ZStack {
            //Background Base
            Rectangle()
                .fill(Color(#colorLiteral(red: 0.05882352963089943, green: 0.10196078568696976, blue: 0.12156862765550613, alpha: 1))).ignoresSafeArea()
            
            //Upper Left Circle
            Circle()
                .fill(LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .init(hex: "48EEC8"), location: 0),
                    .init(color: .init(hex: "48EEC8"), location: 1)]),
                        startPoint: UnitPoint(x: 0.3811188501258659, y: 0.0489510641715612),
                        endPoint: UnitPoint(x: 1.1328670535227703, y: 1.09265733340396)))
                .opacity(70)
                .frame(width: 286, height: 286)
                .offset(x: CGFloat(circle1X), y: CGFloat(circle1Y))
                .onAppear(){
                    withAnimation(.default.speed(0.1).delay(1).repeatForever(autoreverses: true)) {
                        circle1X = -100
                    }
                    withAnimation(.default.speed(0.1).delay(0.3).repeatForever(autoreverses: true)) {
                        circle1Y = -300
                    }
                }
                .blur(radius: 40, opaque: false)
                .ignoresSafeArea()
            
            //Middle Right Circle
            Circle()
                .fill(LinearGradient(
                        gradient: Gradient(stops: [
                    .init(color: .init(hex: "34AF85"), location: 0),
                    .init(color: .init(hex: "5B5EC0"), location: 1)]),
                        startPoint: UnitPoint(x: 0.3811188501258659, y: 0.0489510641715612),
                        endPoint: UnitPoint(x: 1.1328670535227703, y: 1.09265733340396)))
                .opacity(70)
                .frame(width: 216, height: 216)
                .offset(x: CGFloat(circle2X), y: CGFloat(circle2Y))
                .onAppear(){
                    withAnimation(.default.speed(0.1).delay(0.25).repeatForever(autoreverses: true)) {
                        circle2X = 175
                    }
                    withAnimation(.default.speed(0.1).delay(0.75).repeatForever(autoreverses: true)) {
                        circle2Y = 0
                    }
                }
                .blur(radius: 40, opaque: false)
                .ignoresSafeArea()
            
            //Bottom Left Circle
            Circle()
                .fill(LinearGradient(
                        gradient: Gradient(stops: [
                    .init(color: Color(#colorLiteral(red: 0.30588236451148987, green: 0.46666666865348816, blue: 0.6823529601097107, alpha: 1)), location: 0),
                    .init(color: Color(#colorLiteral(red: 0.3843137323856354, green: 0.25882354378700256, blue: 0.772549033164978, alpha: 1)), location: 1)]),
                        startPoint: UnitPoint(x: 0.3811188501258659, y: 0.0489510641715612),
                        endPoint: UnitPoint(x: 1.1328670535227703, y: 1.09265733340396)))
                .offset(x: CGFloat(circle3X), y: CGFloat(circle3Y))
                .onAppear(){
                    withAnimation(.default.speed(0.1).repeatForever(autoreverses: true)) {
                        circle3X = -80
                    }
                    withAnimation(.default.speed(0.1).delay(0.5).repeatForever(autoreverses: true)) {
                        circle3Y = 270
                    }
                }
                .opacity(70)
                .blur(radius: 40, opaque: false)
                .ignoresSafeArea()
                .frame(width: 375, height: 376)
                
            
        }
    }
}

//Global Button Bakground Style
struct ButtonBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
        .fill(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.15000000596046448)))
        .frame(height: 48)
    }
}

//Hex Color Converter
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ContentView: View {
    var body: some View {
        Background()
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Text("hi")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
