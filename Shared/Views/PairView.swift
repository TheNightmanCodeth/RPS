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
        if (!rpsSession.paired && rpsSession.myPeerID.displayName != "6934DBD5-F883-41E8-B006-E49541A79E52") {
            VStack(alignment: .center) {
                Text("Choose Your Opponent!")
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                    .font(.largeTitle)
                Text("Find your friend below to get started!")
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)
                    .font(.subheadline)
                List(rpsSession.availablePeers, id: \.self) { peer in
                    Button(peer.displayName) {
                        rpsSession.serviceBrowser.invitePeer(peer, to: rpsSession.session, withContext: nil, timeout: 30)
                    }.buttonStyle(BorderlessButtonStyle())
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                        .frame(width: 400, alignment: .center)
                }.scrollContentBackgroundCompat(.hidden)
                    .frame(maxWidth: 400, alignment: .center)
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
