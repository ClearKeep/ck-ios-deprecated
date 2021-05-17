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
