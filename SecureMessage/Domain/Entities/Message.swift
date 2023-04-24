//
//  Message.swift
//  SecureMessage
//
//  Created by Justin Lange on 12/12/2022.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var sender: String
    var receiver: String
    var message: String
    var read: Bool
}
