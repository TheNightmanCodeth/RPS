//
//  GameView.swift
//  RPS
//
//  Created by Joe Diragi on 7/29/22.
//

import SwiftUI

struct GameView: View {
    @StateObject var rpsSession: RPSMultipeerSession
    
    @State var timeLeft = 10
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var currentMove: String = "Thinking"
    @State var opponentMove: String = "Thinking"
    
    var body: some View {
        VStack(alignment: .center) {
            // Opponent - 🪨 📄 ✂️
            Image(opponentMove)
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .padding(.top)
                .padding()
            
            // Timer - 10
            Text("\(timeLeft)")
                .font(.system(size: 30))
                .onReceive(timer) { input in
                    if (timeLeft > 0) {
                        timeLeft -= 1
                    } else {
                        timeLeft = 10
                        timer.upstream.connect().cancel()
                        // Call timer.upstream.connect() to restart the timer
                        switch rpsSession.receivedMove {
                        case .rock:
                            opponentMove = "Rock"
                            break
                        case .paper:
                            opponentMove = "Paper"
                            break
                        case .scissors:
                            opponentMove = "Scissors"
                            break
                        default:
                            // TODO: Invalid, big red X or something idk
                            opponentMove = "Thinking"
                            break
                        }
                    }
                }
            // Player - Move
            Image(currentMove)
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .padding()
                .padding(.bottom, 20)
            // Moves - Moves
            HStack {
                Button(action: {
                    currentMove = "Rock"
                    rpsSession.send(move: .rock)
                }, label: {
                    Image("Rock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                })
                    .buttonStyle(BorderlessButtonStyle())
                    .padding()
                
                Button(action: {
                    currentMove = "Paper"
                    rpsSession.send(move: .paper)
                }, label: {
                    Image("Paper")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                })
                    .buttonStyle(BorderlessButtonStyle())
                    .padding()
                
                Button(action: {
                    currentMove = "Scissors"
                    rpsSession.send(move: .scissors)
                }, label: {
                    Image("Scissors")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                })
                    .buttonStyle(BorderlessButtonStyle())
                    .padding()
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(rpsSession: RPSMultipeerSession(username: "TEST"))
    }
}
