//
//  Extensions.swift
//  RPS
//
//  Created by Joe Diragi on 9/2/22.
//

import SwiftUI

// Thanks to https://www.avanderlee.com/swiftui/conditional-view-modifier/ for the tip!
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func ifIOS16<Content: View>(_ transform: (Self) -> Content) -> some View {
        if #available(iOS 16.0, *) {
            transform(self)
        } else {
            self
        }
    }
}

extension List {
    @ViewBuilder
    func scrollContentBackgroundCompat(_ visibility: Visibility) -> some View {
        if #available(iOS 16.0, *) {
            self.scrollContentBackground(visibility)
        }
    }
}

extension Bool {
    static var isIpad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var iOS16: Bool {
        guard #available(iOS 16, *) else {
            return false
        }
        return true
    }
}
