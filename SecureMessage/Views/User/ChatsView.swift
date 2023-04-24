//
//  HomeView.swift
//  SecureMessage
//
//  Created by Justin Lange on 11/12/2022.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ChatsView: View {
    // Views push states
    @State var showingStart: Bool = false
    @State var showingDebug: Bool = false

    // Get the user
    @StateObject private var session = SessionStore()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(session.user?.profile_name ?? "")")
                            .font(.title)
                            .bold()
                            .foregroundColor(.indigo)
                        
                        Text("\(session.user?.email ?? "Loading..")")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.top, 0.25)
                            .padding(.bottom, 25)
                        
                        
                        // Debug Button
                        Button {
                            showingDebug = true
                        } label: {
                            Text("Debug Menu")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 220, height: 50)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        
                        // Sign Out Button
                        Button {
                            if(session.signOut()) {
                                showingStart = true
                            }
                        } label: {
                            Text("Sign Out")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 220, height: 50)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }.padding()
                    Spacer()
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $showingDebug) {
                DebugView()
            }
            .navigationDestination(isPresented: $showingStart) {
                StartView()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        
                    }, label: {
                        Label("Profile", systemImage: "person.crop.circle")
                            .font(.title3)
                            .foregroundColor(.gray)
                    })
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Chats")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .bold()
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        
                    }, label: {
                        Label("Settings", systemImage: "square.and.pencil")
                            .font(.title3)
                    })
                }
            }
            .onAppear(){
                Task {
                    await session.listen()
                }
            }
        }
    }
}

struct ChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsView()
    }
}
