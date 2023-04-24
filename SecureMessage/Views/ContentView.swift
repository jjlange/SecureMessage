//
//  StartView.swift
//  SecureMessage
//
//  Created by Justin Lange on 10/11/2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: SessionStore
    @State var loading = true

    var body: some View {
        VStack {
            if(loading) {
                ProgressView()
            } else {
                if session.user != nil {
                    UserView()
                } else {
                    StartView()
                }
            }
        }.onAppear() {
            Task {
                await session.listen()
                loading = false
            }
        }
    }
}

struct Content_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
