//
//  StartView.swift
//  SecureMessage
//
//  Created by Justin Lange on 10/11/2022.
//

import SwiftUI

struct StartView: View {
    // Views push states
    @State private var showingLogin = false
    @State private var showingSignUp = false
    @State private var showingDebug = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 25) {
                        Text("Welcome to SecureMessage")
                            .font(.largeTitle)
                            .foregroundColor(.indigo)
                            .bold()
                            .onTapGesture(count: 3) {
                                // Open debug view
                                showingDebug = true
                            }
                        
                        Text("Let's get started by setting up your account first. This won't take long. \n\nAfter that you will be able to start new chats and add existing contacts.")
                            .font(.body)
                        
                        HStack {
                            Spacer()
                            
                            NavigationLink(destination: EmptyView()) {
                                Button("Create An Account") {
                                    showingSignUp = true
                                }
                                .tint(.indigo)
                                .font(.title2)
                                .fontWeight(.medium)
                                .buttonStyle(.bordered)
                            }
                            
                            Spacer()
                        }.padding(.top, 25)
                        
                        HStack {
                            Spacer()
                            
                            Button {
                                showingLogin = true
                            } label: {
                                Text("Already have an account? Sign In")
                                    .font(.headline)
                            }
                            .tint(.indigo)
                            Spacer()
                        }
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 25) {
                    Text("Copyright © 2022, SecureMessage.\nThis is a prototype and is not intended for production use.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 25)
                }
            }
            .navigationDestination(isPresented: $showingLogin) {
                LoginView()
            }
            .navigationDestination(isPresented: $showingSignUp) {
                SignUpView()
            }
            .navigationDestination(isPresented: $showingDebug) {
                DebugView()
            }
            .navigationBarBackButtonHidden(true)
            .padding(20)
            .padding(.top, 100)
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
