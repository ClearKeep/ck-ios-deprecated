//
//  MessageBubble.swift
//  ClearKeep
//
//  Created by VietAnh on 1/15/21.
//

import SwiftUI

struct MessageBubble: View {
    var msg : MessageModel
    var userName: String? = nil
    var body: some View {
        // Automatic scroll To Bottom...
        // First Assigning Id To Each Row...
        HStack(alignment: .top,spacing: 10){
            
            if msg.myMsg{
                Spacer(minLength: 25)
                VStack(alignment: .trailing) {
                    if msg.photo == nil{
                        Text(stringValue())
                            .padding(.all, 8)
                            .background(Color.blue)
                            .foregroundColor(Color.white)
                            .clipShape(BubbleArrow(myMsg: msg.myMsg))
                    }
                    else{
                        Image(uiImage: UIImage(data: msg.photo!)!)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width - 150, height: 150)
                            .clipShape(BubbleArrow(myMsg: msg.myMsg))
                    }
                    
                    // Show Time
                    Text(dateTime())
                        .font(.caption)
                        .padding(.top, 5)
                        .foregroundColor(Color.gray.opacity(0.4))
                }
                
                // profile Image...
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            }
            else {
                // profile Image...
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    if let username = self.userName {
                        // Show Time
                        Text(username)
                            .font(.body)
                            .padding(.top, 5)
                            .foregroundColor(Color.black)
                    }
                    if msg.photo == nil{
                        Text(stringValue())
                            .foregroundColor(.black)
                            .padding(.all, 8)
                            .background(Color.black.opacity(0.06))
                            .clipShape(BubbleArrow(myMsg: msg.myMsg))
                    }
                    else {
                        Image(uiImage: UIImage(data: msg.photo!)!)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width - 150, height: 150)
                            .clipShape(BubbleArrow(myMsg: msg.myMsg))
                    }
                    
                    // Show Time
                    Text(dateTime())
                        .font(.caption)
                        .padding(.top, 5)
                        .foregroundColor(Color.gray.opacity(0.4))
                }
                Spacer(minLength: 25)
            }
        }
        .id(msg.id)
    }
    
    private func dateTime() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(msg.createdAt))
        let formatDate = DateFormatter()
        formatDate.dateFormat = "EEE HH:mm"
        return formatDate.string(from: date)
    }
    
    private func stringValue() -> String {
        let str = String(data: msg.message, encoding: .utf8) ?? "x"
        return str
    }
}

struct BubbleArrow : Shape {
    var myMsg : Bool
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: myMsg ?  [.topLeft,.bottomLeft,.bottomRight] : [.topRight,.bottomLeft,.bottomRight], cornerRadii: CGSize(width: 10, height: 10))
        
        return Path(path.cgPath)
    }
}
