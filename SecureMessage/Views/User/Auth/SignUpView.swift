//
//  SignUpView.swift
//  SecureMessage
//
//  Created by Justin Lange on 11/12/2022.
//

import SwiftUI

struct SignUpView: View {
    @State var showDebug: Bool = false
    @State var showUserView: Bool = false
    @State var showingAlert: Bool = false
    
    @State var alertMessage: String = ""
    
    @State var emailField: String = ""
    @State var passwordField: String = ""
    @State var profileDisplayField: String = ""
    
    @ObservedObject var model = SessionStore()

    var body: some View {
       VStack {
              VStack {
                Text("Create An Account")
                     .font(.largeTitle)
                     .bold()
                     .foregroundColor(.indigo)

                Text("Please fill out the information below.")
                     .font(.subheadline)
                     .foregroundColor(.gray)
                     .padding(.bottom, 25)

                TextField("Email", text: $emailField)
                     .padding()
                     .background(Color(.gray))
                     .cornerRadius(5.0)
                     .padding(.bottom, 20)
                     #if os(iOS)
                     .textInputAutocapitalization(.never)
                     #endif
                
                  SecureField("Password", text: $passwordField)
                     .padding()
                     .background(Color(.gray))
                     .cornerRadius(5.0)
                     .padding(.bottom, 20)
                  
                  TextField("Display Name", text: $profileDisplayField)
                       .padding()
                       .background(Color(.gray))
                       .cornerRadius(5.0)
                       .padding(.bottom, 20)
                        #if os(iOS)
                       .textInputAutocapitalization(.never)
                        #endif

                Button {
                    signUp(email: emailField, password: passwordField, profileName: profileDisplayField) }
                label: {
                     Text("Sign Up")
                          .font(.title2)
                          .foregroundColor(.white)
                          .padding()
                          .frame(width: 220, height: 50)
                          .background(Color.indigo)
                          .cornerRadius(15.0)
                }
              }.padding()
           Spacer()

           // Debug View
           NavigationLink(destination: DebugView(), isActive: $showDebug, label: { EmptyView() })

           // User View
            NavigationLink(destination: UserView(), isActive: $showUserView, label: { EmptyView() })
       }.toolbar {
         // Sign Up button
         ToolbarItem(placement: .confirmationAction) {
            NavigationLink(destination: LoginView()) {
                Text("Sign In").foregroundColor(.indigo)
            }
         }

           ToolbarItem(placement: .confirmationAction) {
            Menu {
                Button(action: {
                    showDebug.toggle()
                }) {
                    Label("About SecureMessage", systemImage: "questionmark.circle")
                }
                
                Button(action: {
                    // Open debug view
                    showDebug.toggle()
                }) {
                    Label("Open Debug Menu", systemImage: "ladybug")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }.foregroundColor(.indigo)
         }
       }.alert(isPresented: $showingAlert) {
           Alert(title: Text("Error"),
                 message: Text("\(alertMessage)"),
                 dismissButton: .default(Text("OK")))
       }
    }
    
    
    // Function to trigger the login process
    private func signUp(email: String, password: String, profileName: String) {
        model.signUp(email: email,
                     password: password,
                     profile_name: profileName,
                     bio: "Hi, I am new on SecureMessage!") {
            (user, success, error) in
           if(success) {
               print("Successfully created new account!")
               showUserView.toggle()
           } else {
               alertMessage = error
               showingAlert = true
           }
       }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
