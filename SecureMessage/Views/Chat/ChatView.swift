//
//  DebugViewChat.swift
//  SecureMessage
//
//  Created by Justin Lange on 11/12/2022.
//

import SwiftUI
import FirebaseDatabase
import MLKitTranslate
import FirebaseFirestore
import CryptoKit

struct ChatView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.rootViewDismissal) var rootViewDismissal
    
    var chat: Chat?
    var chatId: String
    var participantId: String
    
    @State private var message: String = ""

    @State private var messages: [Message] = []
    @EnvironmentObject var session: SessionStore
    
    @State var hasConnected = false
    @State var isConnected = false
    @State var isDownloadingLanguagePack = false
    
    @State private var user: User?
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { reader in
                        ChatBubble(type: "system",
                                   content: "This is the beginning of the conversation.")
                        
                        if(isDownloadingLanguagePack) {
                            ChatBubble(type: "system",
                                       content: "Downloading language pack for the first time..")
                        }
                        
                        ForEach(messages, id: \.id) { message in
                            ChatBubble(
                                type: "user",
                                name: message.sender,
                                originalContent: message.message ?? "Nothing yet.",
                                content: (message.sender == session.user?.id ? message.message : message.translated)!,
                                time: (NSDate(timeIntervalSince1970: message.date) as Date),
                                sender: message.sender == session.user?.id)
                        }
                        .onReceive(messages.publisher) { _ in
                            reader.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                }

                Spacer()
                Divider().padding(.top, -8)

                HStack {
                    TextField("Message...", text: $message).lineLimit(20).font(.title3)
                        .onSubmit {
                            // Send a message
                            if(isConnected && message.count > 0) {
                                Task {
                                    await sendMessage(toChat: chatId, message: message, userId: session.user?.id ?? "")
                                }
                            }
                        }
                    Spacer()
                    Button(action: {
                        // Send a message
                        if(isConnected) {
                            Task {
                                await sendMessage(toChat: chatId, message: message, userId: session.user?.id ?? "")
                            }
                        }
                    }, label: {
                        Image(systemName: "arrow.up.circle.fill")
                                .padding(.horizontal)
                                .font(.title)
                                .disabled(isConnected ? false : true)
                    })
                }
                        .padding(.top, 4)
                        .padding(.bottom)
                        .padding(.horizontal)
            }
            .navigationBarBackButtonHidden(true)
                        .navigationBarItems(leading:
                            Button(action: { rootViewDismissal?() }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.blue)
                            }
                        )
            .navigationTitle(isConnected ? "\(user!.profileName)" : "Connecting...")
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
                            if(participantId != nil) {
                                getOtherParticipant(participant: participantId)
                                getMessages(fromChat: chatId)
                            }
                            
                            let connectedRef = Database.database().reference(withPath: ".info/connected")
                            connectedRef.observe(.value, with: { (connected) in
                                if let boolean = connected.value as? Bool, boolean == true {
                                    print("[FB] Connected")
                                    hasConnected = true
                                    isConnected = true
                                } else {
                                    print("[FB] Disconnected")
                                    isConnected = false
                                }
                            })
                        }
                    }
        }
    }
    
    func getOtherParticipant(participant participantId: String) {
        let db = Firestore.firestore()
        db.collection("users").document(participantId).addSnapshotListener { (documentSnapshot, error) in
            // Check for errors
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            let user = User(id: document.documentID,
                            uid: data["uid"] as! String,
                            profileName: data["profile_name"] as! String,
                            bio: data["bio"] as! String,
                            email: data["email"] as! String,
                            suspended: data["suspended"] as! Bool,
                            business: data["business"] as! Bool,
                            verified: data["verified"] as! Bool,
                            profileImage: data["profile_image"] as! String)
            
            self.user = user
        }
    }

    func getMessages(fromChat chatID: String) {
        // Create a reference to the chats node in your Firebase realtime database
        let ref = Database.database().reference().child("chats")
        
        // Query for the chat with the specified ID
        ref.child(chatID).observe(.value) { snapshot in
            // Get the value of the "messages" child key as an array of dictionaries
            if let messagesArray = snapshot.childSnapshot(forPath: "messages").value as? [String : [String : Any]] {
                // Iterate over each message dictionary and create a new Message object
                let group = DispatchGroup()
                var messages: [Message] = []
                
                for (_, messageDictionary) in messagesArray {
                    if let id = messageDictionary["id"] as? String,
                        let sender = messageDictionary["sender"] as? String,
                        let message = messageDictionary["message"] as? String,
                        let date = messageDictionary["date"] as? Double,
                        let read = messageDictionary["read"] as? Bool {
                        
                        group.enter()
                        
                        let conditions = ModelDownloadConditions(
                            allowsCellularAccess: true,
                            allowsBackgroundDownloading: true
                        )
                        
                        let languageMap: [String: TranslateLanguage] = [
                            "english": .english,
                            "german": .german,
                            "italian": .italian,
                            "spanish": .spanish,
                            "chinese": .chinese,
                            "japanese": .japanese,
                            "korean": .korean,
                            "french": .french
                        ]
                        
                        print("Translating message from \(session.user!.language) to \(user!.language)")
                        let sourceLanguageString = user?.language ?? "english"
                        let targetLanguageString = session.user?.language ?? "english"
                        
                        let sourceLanguage = languageMap[sourceLanguageString] ?? .english // Default: English
                        let targetLanguage = languageMap[targetLanguageString] ?? .english // Default: English
                        
                        let options = TranslatorOptions(sourceLanguage: sourceLanguage, targetLanguage: targetLanguage)
                        let translator = Translator.translator(options: options)
                        
                        let models = ModelManager.modelManager().downloadedTranslateModels
                        
                        var sourceModelExists = false
                        var targetModelExists = false
                        
                        for model in models {
                            if(model.name.contains(sourceLanguageString)) {
                                sourceModelExists = true
                            } else if(model.name.contains(targetLanguageString)) {
                                targetModelExists = true
                            }
                        }
                        
                        if(sourceModelExists && targetModelExists) {
                            translator.translate(message) { translatedText, error in
                                defer {
                                    group.leave()
                                }
                                
                                guard error == nil, let translatedText = translatedText else { return }

                                // Translation succeeded.
                                let translated = translatedText
                                
                                let newMessage = Message(id: id, sender: sender, message: message, translated: translated, date:date , read: read)
                                
                                print("[SecureMessage] Added \(newMessage)")
                                messages.append(newMessage)
                            }
                        } else {
                            translator.downloadModelIfNeeded(with: conditions) { error in
                                guard error == nil else {
                                    isDownloadingLanguagePack = false
                                    group.leave()
                                    return
                                }
                                
                                isDownloadingLanguagePack = true
                                
                                translator.translate(message) { translatedText, error in
                                    defer {
                                        isDownloadingLanguagePack = false
                                        group.leave()
                                        
                                    }
                                    
                                    guard error == nil, let translatedText = translatedText else { return }
                                    
                                    // Translation succeeded.
                                    let translated = translatedText
                                    
                                    let newMessage = Message(id: id, sender: sender, message: message, translated: translated, date:date , read: read)
                                    
                                    print("[SecureMessage] Added \(newMessage)")
                                    messages.append(newMessage)
                                }
                            }
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    // Sort the messages by date in ascending order
                    messages.sort { $0.date < $1.date }
                    self.messages = messages
                }
            }
        }
    }

    func sendMessage(toChat chatID: String, message: String, userId: String) async {
        Task {
            // Send a message to the other user
            let ref = Database.database().reference()
            
            let messageRef = ref.child("chats").child(chatID).child("messages").childByAutoId()
            
            let symmetricKey = SymmetricKey(size: .bits256) // Generate a new symmetric key
            
            var messageObject = Message(id: messageRef.key, sender: userId, message: message, date: Date().timeIntervalSince1970, read: false)
            
            do {
                // Create a dictionary of the encrypted message data
                let messageDict = [
                    "id": messageObject.id!,
                    "sender": messageObject.sender,
                    "message": messageObject.message,
                    "date": messageObject.date,
                    "read": messageObject.read
                ] as [String : Any]
                
                try await messageRef.setValue(messageDict) // Send the encrypted message to the database
                
                // Send the symmetric key to the chat participants
                let chatRef = ref.child("chats").child(chatID)
                let symmetricKeyData = symmetricKey.withUnsafeBytes { Data(Array($0)) }
                let encryptionKeyDict = [userId: symmetricKeyData.base64EncodedString()]
                try await chatRef.updateChildValues(encryptionKeyDict)
                
                // Clear the message field
                self.message = ""
            } catch {
                print("error")
            }
        }
    }

}

struct ChatView_Preview: PreviewProvider {
    static var previews: some View {
        ChatView(chatId: "4TALmazKeEcmZKXUSelauYWD7OB2", participantId: "123")
    }
}
