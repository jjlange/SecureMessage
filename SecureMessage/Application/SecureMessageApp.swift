//
//  SecureMessageApp.swift
//  SecureMessage
//
//  Created by Justin Lange on 11/12/2022.
//

import SwiftUI
import FirebaseCore

@main
struct SecureMessageApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(SessionStore())
        }
    }
}
