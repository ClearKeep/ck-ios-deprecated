//
//  MessagerCommonView.swift
//  ClearKeep
//
//  Created by Nguyễn Nam on 5/24/21.
//

import SwiftUI

struct MessagerListView<Content: View>: View {
    
    // MARK: - Variables
    private var listMessageAndSection: [SectionWithMessage] = []
    
    // MARK: - Constants
    private let content: (MessageDisplayInfo) -> Content
    
    // MARK: - Init
    init(messages: [MessageModel], @ViewBuilder content:@escaping (MessageDisplayInfo) -> Content) {
        self.content = content
        self.setupList(messages)
    }
    
    // MARK: - Setup
    private mutating func setupList(_ messages: [MessageModel]) {
        listMessageAndSection = CKExtensions.getMessageAndSection(messages)
    }
    
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

struct MessagerToolBar: View {
    
    // MARK: - Variables
    var sendAction: (String) -> ()
    
    // MARK: - State
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
