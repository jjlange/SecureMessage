//
//  ChatBubble.swift
//  SecureMessage
//
//  Created by Justin Lange on 12/12/2022.
//

import SwiftUI

struct ChatBubble: View {
    @AppStorage("allowTranslations") var allowTranslations: Bool = true
    
    @State private var showOriginal = false
    
    var type: String
    var name: String = "Example"
    var originalContent: String = "Unknown"
    var content: String
    var time: Date = Date()
    var sender: Bool = false
    
    var body: some View {
        if(type == "system") {
            HStack {
                Spacer()
                
                HStack(alignment: .center) {
                    Text(content)
                        .padding(.vertical, 1)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal).padding(.vertical, 8)
                .background(Color.gray.opacity(0.8))
                .cornerRadius(16)
                .frame(maxWidth: 350, alignment: .leading)
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = content
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }
                
                Spacer()
            }.padding()
        } else if(type == "user") {
            HStack {
                if(sender) {
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    Text(allowTranslations ? content : originalContent)
                        .padding(.vertical, 1)
                    
                    if(!sender && allowTranslations) {
                        Button(action: {
                            showOriginal.toggle()
                        }, label: {
                            Text("\(showOriginal ? "Hide" : "Show") original")
                        })
                        
                        if(showOriginal) {
                            Text("Original: \(originalContent)")
                        }
                    }
                    
                    
                    // timestamp
                    if(time.get(.day) == Date().get(.day)) {
                        Text("Today at \(time.getFormattedDate(format: "HH:mm"))")
                            .font(.subheadline)
                            .foregroundColor(sender ? .white : .secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 5)
                    } else {
                        Text("\(time.getFormattedDate(format: "dd/MM/yyyy HH:mm"))")
                            .font(.subheadline)
                            .foregroundColor(sender ? .white : .secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 5)
                    }
                }
                .padding(.horizontal).padding(.vertical, 8)
                .background(sender ? Color.blue.opacity(0.8) : Color.gray.opacity(0.5))
                .cornerRadius(16)
                .frame(maxWidth: 250, alignment: .leading)
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = content
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    
                    ShareLink(item: "\(content) \(" - Original: \(originalContent)")") {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
                
                if(!sender) {
                    Spacer()
                }
            }.padding()
        }
    }
}


// TODO: move somewhere else
extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
    
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}


struct ChatBubble_Previews: PreviewProvider {
    static var previews: some View {
        ChatBubble(
            type: "user",
            name: "Test",
            originalContent: "Hallo Welt!",
            content: "Hello world!",
            time: Date(),
            sender: false)
    }
}
