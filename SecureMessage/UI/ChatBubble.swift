//
//  ChatBubble.swift
//  SecureMessage
//
//  Created by Justin Lange on 12/12/2022.
//

import SwiftUI

struct ChatBubble: View {
    var name: String
    var content: String
    var time: String
    var sender: Bool
    
    var body: some View {
        HStack {
            if(sender) {
                Spacer()
            }
            VStack(alignment: .leading) {
                        // header
                        HStack {
                            if(sender) {
                                Spacer()
                            }
                            Text(name)
                            if(!sender) {
                                Spacer()
                            }
                        }
                        .foregroundColor(sender ? .secondary : .white)
                        
                        // text
                        Text(content)
                            .padding(.vertical, 5)
                        
                        // timestamp
                        Text(time)
                            .font(.subheadline)
                            .foregroundColor(sender ? .secondary : .white)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                    }
                    .padding()
                    .background(sender ? Color.gray.opacity(0.5) : Color.blue.opacity(0.8))
                    .cornerRadius(16)
                    .frame(maxWidth: 250, alignment: .leading)
            if(!sender) {
                Spacer()
            }
        }.padding()
    }
}

struct ChatBubble_Previews: PreviewProvider {
    static var previews: some View {
        ChatBubble(name: "Test", content: "Hello, world!", time: "12:00 PM", sender: false)
    }
}
