//
//  RPSApp.swift
//  Shared
//
//  Created by builder on 9/1/22.
//

import SwiftUI

@main
struct RPSApp: App {
    
    init() {
        if #unavailable(iOS 16.0) {
            UITableView.appearance().backgroundColor = .clear
        }
    }
    
    var body: some Scene {
        WindowGroup {
            StartView()
        }
    }
}
