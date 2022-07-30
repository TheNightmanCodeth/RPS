//
//  StartView.swift
//  RPS
//
//  Created by Joe Diragi on 7/28/22.
//

import SwiftUI

struct StartView: View {
    @State var username = ""
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Nickname", text: $username)
                    .padding([.horizontal], 75.0)
                    .modifier(TextFieldSubmit(username: $username))
            }
        }
        #if os(macOS)
        .frame(minWidth: 500, maxWidth: 500, minHeight: 500, maxHeight: 500)
        #endif
    }
}

struct TextFieldSubmit: ViewModifier {
    @Binding var username: String
    
    func body(content: Content) -> some View {
        HStack {
            content
            
            if !username.isEmpty {
                
                NavigationLink(destination: PairView(rpsSession: RPSMultipeerSession(username: username))) {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(Color(.gray))
                }
                // There has to be a better way, but for now it works <3
                // TODO: Fix inline submit button alignment
                #if os(macOS)
                .offset(x: -110)
                .buttonStyle(BorderlessButtonStyle())
                .keyboardShortcut(KeyEquivalent.return)
                #endif
            }
        }
    }
}
