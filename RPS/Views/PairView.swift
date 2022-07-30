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
        HStack {
            List(rpsSession.availablePeers, id: \.self) { peer in
                Button(peer.displayName) {
                    rpsSession.serviceBrowser.invitePeer(peer, to: rpsSession.session, withContext: nil, timeout: 10)
                }
            }
        }
        .alert("Received an invite!", isPresented: $rpsSession.recvdInvite) {
            Text("\(rpsSession.recvdInviteFrom?.displayName ?? "") wants to play!")
            Button("Accept invite") {
                rpsSession.session.nearbyConnectionData(forPeer: rpsSession.recvdInviteFrom!, withCompletionHandler: { data, error in
                    if (data != nil) {
                        rpsSession.session.connectPeer(rpsSession.recvdInviteFrom!, withNearbyConnectionData: data!)
                        DispatchQueue.main.async {
                            rpsSession.connectedPeer = rpsSession.recvdInviteFrom
                        }
                        logger.info("Connectedpeer")
                    } else {
                        // Something's wrong
                        // TODO: Tell user there was an error connecting
                    }
                })
                
            }
        }
    }
}
