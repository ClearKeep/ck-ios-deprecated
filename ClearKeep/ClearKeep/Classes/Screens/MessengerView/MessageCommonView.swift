//
//  MessageCommonView.swift
//  ClearKeep
//
//  Created by Nguyễn Nam on 5/17/21.
//

import SwiftUI

struct MessageListView<Content: View>: View {
    
    private var listMessageAndSection: [SectionWithMessage] = []
    private let content: (MessageDisplayInfo) -> Content
    
    init(messages: [MessageModel], @ViewBuilder content:@escaping (MessageDisplayInfo) -> Content) {
        self.content = content
        self.setupList(messages)
    }
    
    // setupList(_:) Converts your array into multi-dimensional array.
    private mutating func setupList(_ messages: [MessageModel]) {
        listMessageAndSection = CKExtensions.getMessageAndSection(messages)
    }
    
    // The Magic goes here
    var body: some View {
        VStack(spacing: 8) {
            ForEach(listMessageAndSection , id: \.title) { gr in
                Section(header: Text(gr.title)
                            .font(AppTheme.fonts.textSmall.font)
                            .foregroundColor(AppTheme.colors.gray3.color)) {
                    let listDisplayMessage = MessageUtils.getListRectCorner(messages: gr.messages)
                    ForEach(listDisplayMessage , id: \.message.id) { msg in
                        content(msg)
                    }
                }
            }
        }
        .padding([.horizontal,.bottom])
        .padding(.top, 25)
    }
}

struct MessageToolBar: View {
    
    var sendAction: (String) -> ()
    @State private var messageText: String = ""
    
    var body: some View {
        HStack(spacing: 15) {
            Button {} label: {
                Image("ic_photo")
                    .foregroundColor(AppTheme.colors.gray1.color)
            }
            Button {} label: {
                Image("ic_tag")
                    .foregroundColor(AppTheme.colors.gray1.color)
            }
            
            MultilineTextField("Type Something Here", text: $messageText)
                .padding(.vertical, 4)
                .padding(.horizontal)
                .background(AppTheme.colors.gray5.color)
                .cornerRadius(16)
                .clipped()
            
            // Send Button...
            Button(action: {
                // appeding message...
                // adding animation...
                withAnimation(.easeIn){
                    sendAction(messageText)
                }
                messageText = ""
            }, label: {
                Image("ic_sent")
                    .foregroundColor(AppTheme.colors.primary.color)
            })
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .animation(.easeOut)
    }
}
