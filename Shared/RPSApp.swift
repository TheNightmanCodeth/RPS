//
//  RPSApp.swift
//  Shared
//
//  Created by builder on 9/1/22.
//

import SwiftUI

@main
struct RPSApp: App {
    
    #if os(iOS)
    init() {
        if #unavailable(iOS 16.0) {
            UITableView.appearance().backgroundColor = .clear
        }
    }
    #endif
    
    var body: some Scene {
        WindowGroup {
            StartView()
        }
    }
}
