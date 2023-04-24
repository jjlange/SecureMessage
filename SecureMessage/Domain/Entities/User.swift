//
//  User.swift
//  SecureMessage
//
//  Created by Justin Lange on 10/12/2022.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var uid: String
    var profile_name: String
    var bio: String
    var email: String
    var suspended: Bool
    var business: Bool
    var verified: Bool
}
