//
//  DebugViewChat.swift
//  SecureMessage
//
//  Created by Justin Lange on 11/12/2022.
//

import SwiftUI
import FirebaseDatabase

struct DebugViewChat: View {
    var receiverId: String
    @State private var message: String = ""

    @State private var messages: [Message] = []
    @StateObject private var session = SessionStore()

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { reader in
                        ForEach(messages, id: \.id) { message in
                            ChatBubble(name: message.sender, content: message.message, time: "12:00 PM", sender: message.sender == session.user?.id)
                        }.onReceive(messages.publisher) { _ in
                            reader.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                }

                Spacer()
                Divider()
                        .padding(.top, -8)

                HStack {
                    TextField("Message...", text: $message).lineLimit(20).font(.title3)
                    Spacer()
                    Button(action: {
                        // Send a message
                        Task {
                            await sendMessage(message: message, userId: session.user?.id ?? "")
                        }
                    }, label: {
                        Text("Send")
                                .padding(.horizontal)
                                .font(.title3)
                    })
                }
                        .padding(.top, 4)
                        .padding(.bottom)
                        .padding(.horizontal)
            }
            .navigationTitle("Demo Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        
                    }, label: {
                        Label("Settings", systemImage: "gearshape")
                    })
                }
            }
                    .onAppear() {
                        Task {
                            await session.listen()
                            await getMessages()
                        }
                    }
        }
    }

    func getMessages() async {
        // Get latest messages
        let db = Database.database().reference()
        let messagesRef = db.child("messages")

        messagesRef.queryLimited(toLast: 100).observe(DataEventType.value, with: { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let message = Message(id: child.key, sender: child.childSnapshot(forPath: "sender").value as! String, receiver: child.childSnapshot(forPath: "receiver").value as! String, message: child.childSnapshot(forPath: "message").value as! String, read: child.childSnapshot(forPath: "read").value as! Bool)

                // Replace the message if it already exists
                if let index = messages.firstIndex(where: { $0.id == message.id }) {
                    messages[index] = message
                } else {
                    messages.append(message)
                }
            }
        })
    }

    func sendMessage(message: String, userId: String) async {
        // Send a message to the other user
        let ref = Database.database().reference()

        let messageRef = ref.child("messages").childByAutoId()
        let message = Message(id: messageRef.key, sender: userId, receiver: receiverId, message: message, read: false)

        // new dictionary
        let messageDict = [
            "id": message.id,
            "sender": message.sender,
            "receiver": message.receiver,
            "message": message.message,
            "read": message.read
        ] as [String : Any]
        do {
            try await messageRef.setValue(messageDict)
        } catch {
            print("error")
        }

        // Clear the message field
        self.message = ""
    }
}

struct DebugViewChat_Previews: PreviewProvider {
    static var previews: some View {
        DebugViewChat(receiverId: "4TALmazKeEcmZKXUSelauYWD7OB2")
    }
}
