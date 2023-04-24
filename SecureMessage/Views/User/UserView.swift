//
//  UserView.swift
//  SecureMessage
//
//  Created by Justin Lange on 11/12/2022.
//

import SwiftUI

struct UserView: View {
    var body: some View {
        VStack {
            TabView {
                ChatsView()
                .tabItem { 
                    Label("Chats", systemImage: "bubble.middle.bottom")
                }
                
                VStack() {
                    Text("Settings View")
                }
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            }
        }.navigationBarBackButtonHidden(true)
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}
