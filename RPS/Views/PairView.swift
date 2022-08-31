//
//  PairView.swift
//  RPS
//
//  Created by Joe Diragi on 7/29/22.
//

import SwiftUI
import os

struct PairView: View {
    @EnvironmentObject var rpsSession: RPSMultipeerSession
    
    @Binding var currentView: Int
    var logger = Logger()
        
    var body: some View {
        if (!rpsSession.paired) {
            HStack {
                List(rpsSession.availablePeers, id: \.self) { peer in
                    Button(peer.displayName) {
                        rpsSession.serviceBrowser.invitePeer(peer, to: rpsSession.session, withContext: nil, timeout: 30)
                    }
                }
            }
            .alert("Received an invite from \(rpsSession.recvdInviteFrom?.displayName ?? "ERR")!", isPresented: $rpsSession.recvdInvite) {
                Button("Accept invite") {
                    if (rpsSession.invitationHandler != nil) {
                        rpsSession.invitationHandler!(true, rpsSession.session)
                    }
                }
                Button("Reject invite") {
                    if (rpsSession.invitationHandler != nil) {
                        rpsSession.invitationHandler!(false, nil)
                    }
                }
            }
        } else {
            GameView(currentView: $currentView)
                .environmentObject(rpsSession)
        }
    }
}
