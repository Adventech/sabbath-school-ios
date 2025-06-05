/*
 * Copyright (c) 2024 Adventech <info@adventech.io>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SwiftUI
import SwiftEntryKit

struct ResourceCommentView: View {
    @State var comment: String
    @State var block: AnyBlock
    @State var markdown: String
    @State var blockId: String? = nil
    @EnvironmentObject var viewModel: DocumentViewModel
    @EnvironmentObject var paragraphViewModel: ParagraphViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    SwiftEntryKit.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(themeManager.getTextColor())
                }
                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            VStack {
                InlineAttributedText(
                    block: AnyBlock(block),
                    markdown: markdown,
                    selectable: false,
                    lineLimit: 3,
                    styleTemplate: EmbeddedBlockStyleTemplate(),
                    urlsEnabled: false
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }.padding(20)
            
            Divider()
            
            VStack {
                TextEditor(text: $comment)
                    .font(Font.custom("Lato-Regular", size: BlockStyleTemplate().textSizePoints(.base)))
                    .padding(.horizontal, 20)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .scrollContentBackground(.hidden)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                    }
                    
                    .overlay(alignment: .bottomTrailing) {
                        Button (action: {
                            saveComment()
                            SwiftEntryKit.dismiss()
                        }) {
                            Image(systemName: "paperplane.fill")
                                .imageScale(.large)
                                .foregroundColor(.black | .white)
                                .rotationEffect(.degrees(45))
                                .padding(.bottom, 20)
                                .padding(.trailing, 20)
                        }
                    }
            }
            
        }
        .background(themeManager.backgroundColor)
        .cornerRadius(6)
    }
    
    func saveComment() {
        if blockId == nil {
            self.paragraphViewModel.setComment(comment: comment)
        }
        
        // Currently ugly, but this is the case where the comment is being made upon the paragraph that is shown in the modal
        if let blockId = blockId, viewModel.document != nil {
            let userInput = AnyUserInput(UserInputComment(blockId: blockId, inputType: .comment, comment: comment, timestamp: Int(Date().timeIntervalSince1970)))
            viewModel.saveBlockUserInput(
                documentId: viewModel.document?.id,
                blockId: blockId,
                userInputType: .comment,
                userInput: userInput)
            
            // Updating documentViewModel with the new user input
            if let index = viewModel.documentUserInput.firstIndex(where: { $0.blockId == userInput.blockId && $0.inputType == userInput.inputType }) {
                viewModel.documentUserInput[index] = userInput
            } else {
                viewModel.documentUserInput.append(userInput)
            }
        }
    }
}
