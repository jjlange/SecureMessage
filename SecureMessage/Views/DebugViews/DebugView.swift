//
// Created by Justin Lange on 11/12/2022.
//

import SwiftUI

struct Trail: Identifiable {
    var id = UUID()
    var name: String
    var description: String
    var location: AnyView
}

struct TrailRow: View {
    var trail: Trail
    
    var body: some View {
        HStack {
            NavigationLink(destination: trail.location, label: {
                VStack(alignment: .leading) {
                    Text(trail.name)
                    Text(trail.description).font(.subheadline).foregroundColor(.gray)
                }
            })
        }
    }
}

struct DebugView: View {
    @Environment(\.presentationMode) private var presentationMode
        let testing = [
            Trail(name: "Use Demo Account", description: "Sign in as demo@demo.com for testing purposes.", location: AnyView(EmptyView())),
            Trail(name: "List Users", description: "See current registered users in the database.", location: AnyView(DebugViewUsers())),
            Trail(name: "Open Chat Demo (Justin)", description: "Open chat with the user 'Justin'", location: AnyView(DebugViewChat(receiverId: "QYpRbUHfwHakp84D2TKPK07LHPl2"))),
            Trail(name: "Open Chat Demo (Test)", description: "Open chat with the user 'Test' (hello@hello.com)", location: AnyView(DebugViewChat(receiverId: "4TALmazKeEcmZKXUSelauYWD7OB2")))
        ]


       var body: some View {
            VStack {
                   List {
                       Section(header: Text("Testing"), footer: Text("These options are used for internal testing and demo purposes.")) {
                           ForEach(testing) { test in
                               TrailRow(trail: test)
                           }
                       }

                       Section(header: Text("Development"), footer: Text("These options are used for development purposes.")) {
                           Button(action: {
                               let domain = Bundle.main.bundleIdentifier!
                               UserDefaults.standard.removePersistentDomain(forName: domain)
                               UserDefaults.standard.synchronize()
                               print("Cleared Data")
                           }, label: {
                               VStack(alignment: .leading) {
                                   Text("Clear App Data")
                                   Text("e.g. UserDefaults").font(.subheadline).foregroundColor(.gray)
                               }
                           })
                       }
                   }

                   Text("This is an internal testing program. Do Not Distribute.\nVersion 1.0.0")
                       .font(.footnote)
                       .foregroundColor(.gray)
               }
               #if os(iOS)
               .navigationBarTitle("Debug Menu")
               .navigationBarTitleDisplayMode(.inline)
               #endif
       }
}
