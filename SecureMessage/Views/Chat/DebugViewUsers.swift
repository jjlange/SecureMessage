//
//  DebugViewUsers.swift
//  SecureMessage
//
//  Created by Justin Lange on 11/12/2022.
//

import SwiftUI
import FirebaseFirestore

struct DebugViewUsers: View {
    @State var users: [User] = []
    @State var loading: Bool = true
    
    var body: some View {
        VStack {
            if(loading) {
                ProgressView()
            } else {
                List {
                    ForEach(users) { user in
                        VStack(alignment: .leading) {
                            Text("\(user.profileName)").font(.title3).bold()
                            Text("**ID:** \(user.uid)").font(.subheadline).foregroundColor(.gray)
                            Text("**Email:** \(user.email)").font(.subheadline).foregroundColor(.gray)
                            Text("**Verified:** \(user.verified ? "Yes" : "No")").font(.subheadline).foregroundColor(.gray)
                            Text("**Suspended:** \(user.suspended ? "Yes" : "No")").font(.subheadline).foregroundColor(.gray)
                            Text("**Account Type:** \(user.business ? "Business" : "Personal")").font(.subheadline).foregroundColor(.gray)
                            Text("\nBio:").font(.headline)
                            Text("\(user.bio.count > 0 ? user.bio : "No bio added.")").font(.subheadline).foregroundColor(.gray)
                            
                            // Delete button
                            Button {
                                // Delete user
                                Firestore.firestore().collection("users").document(user.id!).delete()

                                // Remove from list
                                users.removeAll(where: { $0.id == user.id })

                                // Add new user to collection
                                Firestore.firestore().collection("users").addDocument(data: [
                                    "uid": user.uid,
                                    "profile_name": user.profileName,
                                    "bio": "",
                                    "email": user.email,
                                    "suspended": false,
                                    "business": false,
                                    "verified": false
                                ])

                                // Add new user to list
                                users.append(User(id: nil, uid: user.uid, profileName: user.profileName, bio: "", email: user.email, suspended: false, business: false, verified: false, profileImage: ""))

                            } label: {
                                Text("Delete Data")
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .padding(2)
                                    .frame(width: 100, height: 30)
                                    .background(Color.red)
                                    .cornerRadius(5)
                            }
                        }
                    }
                }
            }
        }.onAppear(perform: {
            let db = Firestore.firestore()

            db.collection("users").getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let result = Result {
                            try document.data(as: User.self)
                        }
                        
                        switch result {
                        case .success(let user):
                            users.append(user)
                            loading = false
                        case .failure(let error):
                            print("Error decoding user: \(error)")
                        }
                    }
                }
            }
        }).navigationTitle("Users")
    }
}

struct DebugViewUsers_Previews: PreviewProvider {
    static var previews: some View {
        DebugViewUsers()
    }
}
