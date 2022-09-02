//
//  GameView.swift
//  RPS
//
//  Created by Joe Diragi on 7/29/22.
//

import SwiftUI
import Combine

enum Result {
    case win, loss, tie
}

struct GameView: View {
    @EnvironmentObject var rpsSession: RPSMultipeerSession
    
    @Binding var currentView: Int
    @State var timeLeft = 10
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var currentMove: Move = .unknown
    @State var opponentMove: Move = .unknown
    @State var showResult: Bool = false
    @State var result: Result = .tie
    @State var resultMessage: String = ""
    
    @State var rematchReceiver: AnyCancellable?
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                Spacer()
                // Opponent - 🪨 📄 ✂️
                Image(opponentMove.description)
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
                                opponentMove = .rock
                                break
                            case .paper:
                                opponentMove = .paper
                                break
                            case .scissors:
                                opponentMove = .scissors
                                break
                            default:
                                // TODO: Invalid, big red X or something idk
                                opponentMove = .unknown
                                break
                            }
                            //TODO: Show winning/losing screen and restart button
                            result = score(opponentMove: opponentMove, ourMove: currentMove)
                            if (result == .win) {
                                resultMessage = "You won!"
                            } else if (result == .loss) {
                                resultMessage = "You lost!"
                            } else {
                                resultMessage = "It's a tie!"
                            }
                            showResult = true
                        }
                    }
                // Player - Move
                Image(currentMove.description)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .padding()
                    .padding(.bottom, 20)
                // Moves - Moves
                HStack {
                    Button(action: {
                        currentMove = .rock
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
                        currentMove = .paper
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
                        currentMove = .scissors
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
                Spacer()
            }
            if (showResult) {
                VStack(alignment: .center, spacing: 10) {
                    Text(resultMessage)
                        .fontWeight(.heavy)
                    Text("Would you like to play again?")
                        .fontWeight(.regular)
                    Button("Yes") {
                        rpsSession.sendRematch()
                        showResult = false
                        timer = timer.upstream.autoconnect()
                    }
                    Button("No") {
                        rpsSession.session.disconnect()
                        if rpsSession.myPeerID.displayName == "6934DBD5-F883-41E8-B006-E49541A79E52" {
                            currentView = 0
                        }
                    }
                }.zIndex(1)
                    .frame(width: 400, height: 500)
                    .background(Color.white)
                    .cornerRadius(12)
            }
        }.onAppear {
            rematchReceiver = rpsSession.$rematch.receive(on: DispatchQueue.main).sink { val in
                if val {
                    showResult = false
                    timer = timer.upstream.autoconnect()
                }
            }
        }.onDisappear {
            rematchReceiver!.cancel()
        }
    }
    
    func score(opponentMove: Move, ourMove: Move) -> Result {
        switch opponentMove {
        case .rock:
            if ourMove == .scissors {
                return .loss
            } else if ourMove == .paper {
                return .win
            } else {
                return .tie
            }
        case .paper:
            if ourMove == .rock {
                return .loss
            } else if ourMove == .scissors {
                return .win
            } else {
                return .tie
            }
        case .scissors:
            if ourMove == .paper {
                return .loss
            } else if ourMove == .rock {
                return .win
            } else {
                return .tie
            }
        default:
            // Invalid move somewhere
            return .tie
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(currentView: .constant(0))
            .environmentObject(RPSMultipeerSession(username: "TEST"))
    }
}
