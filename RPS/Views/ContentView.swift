//
//  ContentView.swift
//  RPS
//
//  Created by Joe Diragi on 7/28/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var rpsSession: RPSMultipeerSession
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ForEach(Move.allCases, id: \.self) { move in
                    Button(move.rawValue) {
                        rpsSession.send(move: move)
                    }
                    .padding()
                }
            }
            Spacer()
            
            Text(rpsSession.receivedMove?.rawValue ?? "Waiting")
        }
        .padding()
        .navigationTitle(rpsSession.username)
    }
}

