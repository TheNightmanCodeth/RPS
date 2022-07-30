//
//  PairView.swift
//  RPS
//
//  Created by Joe Diragi on 7/29/22.
//

import SwiftUI
import os

struct PairView: View {
    @StateObject var rpsSession: RPSMultipeerSession
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
            /*
            .alert("Received an invite from \(rpsSession.recvdInviteFrom?.displayName ?? "ERR")!", isPresented: $rpsSession.recvdInvite) {
                Button("Accept invite") {
                    rpsSession.session.nearbyConnectionData(forPeer: rpsSession.recvdInviteFrom!, withCompletionHandler: { (data, error) in
                        if (data != nil) {
                            rpsSession.session.connectPeer(rpsSession.recvdInviteFrom!, withNearbyConnectionData: data!)
                            rpsSession.start()
                            DispatchQueue.main.async {
                                rpsSession.connectedPeer = rpsSession.recvdInviteFrom
                                rpsSession.paired = true
                            }
                        } else {
                            // Something's wrong
                            // TODO: Tell user there was an error connecting
                        }
                    })
                    
                }
            }*/
        } else {
            GameView(rpsSession: rpsSession)
        }
    }
}
