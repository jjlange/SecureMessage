//
//  AuthViewModel.swift
//  SecureMessage
//
//  Created by Justin Lange on 09/12/2022.
//

import FirebaseAuth
import FirebaseFirestore
import Combine

class SessionStore: ObservableObject {
    var handle: AuthStateDidChangeListenerHandle?
    @Published var didChange = PassthroughSubject<SessionStore, Never>()
    @Published var user: User? { didSet { self.didChange.send(self) } }

    func listen() async {
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if let user = user {
                // Get the user data from Firestore
                let db = Firestore.firestore()

                db.collection("users").document(user.uid).addSnapshotListener { (documentSnapshot, error) in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }

                    guard let data = document.data() else {
                        print("Document data was empty.")
                        return
                    }

                    self.user = User(id: document.documentID, uid: data["uid"] as! String, profile_name: data["profile_name"] as! String, bio: data["bio"] as! String, email: data["email"] as! String, suspended: data["suspended"] as! Bool, business: data["business"] as! Bool, verified: data["verified"] as! Bool)
                }
            } else {
                self.user = nil
            }
        })
    }

    // Function to remove the listener
    func unbind() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // Function to sign in with email and password
    func signIn(email: String, password: String, completion: @escaping (_ user: User?, _ success: Bool, _ error: String) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            // Check if user is logged in
            if authResult?.user != nil {
                // Get user data
                let db = Firestore.firestore()
                print(Auth.auth().currentUser!.uid)
                let docRef = db.collection("users").document(Auth.auth().currentUser!.uid)

                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let result = Result {
                            try document.data(as: User.self)
                        }
                        switch result {
                        case .success(let user):
                            self.user = user
                            completion(user, true, "")
                        case .failure(let error):
                            print("Error decoding user: \(error)")
                            completion(nil, false, error.localizedDescription)
                        }
                    } else {
                        completion(nil, false, error?.localizedDescription ?? "Something went wrong.")
                    }
                }
            } else {
                completion(nil, false, error?.localizedDescription ?? "Something went wrong.")
            }
        }
    }

    // Function to sign up with email and password
    func signUp(email: String, password: String, profile_name: String, bio: String, completion: @escaping (_ user: User?, _ success: Bool, _ error: String) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if authResult?.user != nil {
                // Create a new user in Firestore
                let db = Firestore.firestore()
                let user = User(uid: Auth.auth().currentUser!.uid, profile_name: profile_name, bio: bio, email: email, suspended: false, business: false, verified: false)

                do {
                    let _ = try db.collection("users").document(user.uid).setData(from: user)
                    self.user = user
                    completion(user, true, "")
                } catch {
                    completion(nil, false, error.localizedDescription)
                }
            } else {
                completion(nil, false, error?.localizedDescription ?? "Something went wrong.")
            }
        }
    }

    // Function to sign out the user
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            self.user = nil
            return true
        } catch {
            return false
        }
    }
}
