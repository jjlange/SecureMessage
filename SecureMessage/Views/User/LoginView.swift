//
//  LoginView.swift
//  SecureMessage
//
//  Created by Justin Lange on 11/12/2022.
//

import SwiftUI

struct LoginView: View {
    @State var showDebug: Bool = false
    @State var showUserView: Bool = false
    @State var showingAlert: Bool = false
    
    @State var alertMessage: String = ""
    
    @State var emailField: String = ""
    @State var passwordField: String = ""
    
    @ObservedObject var model = SessionStore()

    var body: some View {
       VStack {
              VStack {
                Text("Sign In")
                     .font(.largeTitle)
                     .bold()
                     .foregroundColor(.indigo)

                Text("Use your email address and password to sign in.")
                     .font(.subheadline)
                     .foregroundColor(.gray)
                     .padding(.bottom, 25)

                TextField("Email", text: $emailField)
                     .padding()
                     .background(.gray)
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

                Button {
                    login(email: emailField, password: passwordField) }
                label: {
                     Text("Sign In")
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
            NavigationLink(destination: SignUpView()) {
                Text("Sign Up").foregroundColor(.indigo)
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
    private func login(email: String, password: String) {
       model.signIn(email: email, password: password) {
           (user, success, error) in
           if(success) {
               showUserView.toggle()
           } else {
              alertMessage = error
              showingAlert = true
           }
       }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
