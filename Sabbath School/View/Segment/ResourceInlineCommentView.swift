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

struct ResourceInlineCommentView: View {
    @State var comment: String
    @State var block: AnyBlock
    @State var markdown: String
    @State var blockId: String? = nil
    @State var startIndex: Int
    @State var endIndex: Int
    @State var length: Int
    @State var inlineComment: UserInputInlineComment? = nil
    @EnvironmentObject var viewModel: DocumentViewModel
    @EnvironmentObject var paragraphViewModel: ParagraphViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    @FocusState private var isFocused: Bool
    
    @State private var showDeleteAlert = false
    
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
                    urlsEnabled: false,
                    startFrom: startIndex
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }.padding(20)
            
            Divider()
            
            VStack {
                TextEditor(text: $comment)
                    .font(Font.custom("Lato-Regular", size: BlockStyleTemplate().textSizePoints(.base)))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 60)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .scrollContentBackground(.hidden)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                    }
                    .overlay(alignment: .bottom) {
                        HStack {
                            if inlineComment != nil {
                                Button (action: {
                                    showDeleteAlert = true
                                }) {
                                    Image(systemName: "trash")
                                        .imageScale(.large)
                                        .foregroundColor(.red | .white)
                                        .padding(.bottom, 20)
                                        .padding(.leading, 20)
                                }
                            }
                            Spacer()
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
                    .alert("Are you sure you want to delete?", isPresented: $showDeleteAlert) {
                        Button("Delete", role: .destructive) {
                            deleteComment()
                            SwiftEntryKit.dismiss()
                        }
                        Button("Cancel", role: .cancel) {
                            showDeleteAlert = false
                        }
                    } message: {
                        Text("This action cannot be undone.")
                    }
            }
            
        }
        .background(themeManager.backgroundColor)
        .cornerRadius(6)
    }
    
    func saveComment() {
        if inlineComment == nil {
            self.paragraphViewModel.setInlineComment(startIndex: startIndex, endIndex: endIndex, length: length, color: .yellow, comment: comment)
        } else if viewModel.document != nil, let inlineComment = inlineComment, let existingIndex = self.paragraphViewModel.inlineComments.firstIndex(where: { $0.id == inlineComment.id }) {
            var a = self.paragraphViewModel.inlineComments
            a[existingIndex].comment = comment
            self.paragraphViewModel.inlineComments = []
            
            let userInput = AnyUserInput(UserInputInlineComments(blockId: block.id, inputType: .inlineComments, inlineComments: a, timestamp: Int(Date().timeIntervalSince1970)))
            
            viewModel.saveBlockUserInput(
                documentId: viewModel.document?.id,
                blockId: block.id,
                userInputType: .inlineComments,
                userInput: userInput)
        }
    }
    
    func deleteComment() {
        if let inlineComment = inlineComment,
           let index = self.paragraphViewModel.inlineComments.firstIndex(where: { $0.id == inlineComment.id }) {
            self.paragraphViewModel.inlineComments.remove(at: index)
            
            let userInput = AnyUserInput(UserInputInlineComments(blockId: block.id, inputType: .inlineComments, inlineComments: self.paragraphViewModel.inlineComments, timestamp: Int(Date().timeIntervalSince1970)))
            
            viewModel.saveBlockUserInput(
                documentId: viewModel.document?.id,
                blockId: block.id,
                userInputType: .inlineComments,
                userInput: userInput)
        }
    }
}
