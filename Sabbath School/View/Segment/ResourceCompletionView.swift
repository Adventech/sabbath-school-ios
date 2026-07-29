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
import Combine

struct ResourceCompletionView: View {
    @State var completionId: String
    @State var completion: CompletionData
    @State var block: AnyBlock
    @State var blockId: String? = nil
    
    @State var comment: String = ""
    
    @EnvironmentObject var viewModel: DocumentViewModel
    @EnvironmentObject var paragraphViewModel: ParagraphViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    @State var tipShown: Bool = false
    
    @State private var typingTimer: Timer? = nil
    let delay: TimeInterval = 2.0
    
    @FocusState private var isFocused: Bool
    
    var placeholder: String {
        let s = (completion.length >= 0) && completion.correctCompletion != nil ? completion.correctCompletion!.replacingOccurrences(of: "\\S", with: "_", options: .regularExpression) : String(repeating: "_", count: 10)
        
        let prefix = comment.prefix(s.count)
        let suffix = s.dropFirst(comment.count)
        return String(prefix + suffix)
    }
    
    var isCorrect: Bool {
        if let correct = completion.correctCompletion {
            return comment.caseInsensitiveCompare(correct) == .orderedSame
        }
        return false
    }
    
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
                
                if let correctAnswer = completion.correctCompletion {
                    Button(action: {
                        tipShown.toggle()
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(themeManager.getTextColor())
                    }.alwaysPopover(isPresented: $tipShown) {
                        Text(correctAnswer).padding()
                    }
                }
                
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                if completion.length > 0 {
                    VStack(spacing: 10) {
                        Text(placeholder)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(isCorrect ? .green : .gray)
                            .tracking(10)
                            .lineSpacing(20)
                            .lineLimit(2)
                            .font(.system(size: 45).monospaced())
                            .multilineTextAlignment(.center)
                        
                        Divider()
                    }
                }
                
                TextEditor(text: $comment)
                    .onChange(of: comment) { newValue in
                        saveCompletionWithDelay()
                    }
                    .font(Font.custom("Lato-Regular", size: BlockStyleTemplate().textSizePoints(.base)))
                    .padding(.horizontal, 20)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .scrollContentBackground(.hidden)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .focused($isFocused)
                    .autocapitalization(.none)
                    .onAppear {
                        isFocused = true
                    }
                    .onReceive(Just(comment)) {_ in
                        if completion.length > 0 {
                            limitText(completion.length)
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        Button (action: {
                            typingTimer?.invalidate()
                            saveCompletion()
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
    
    func limitText(_ upper: Int) {
        if comment.count > upper {
            comment = String(comment.prefix(upper))
        }
    }
    
    func saveCompletionWithDelay() {
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            DispatchQueue.main.async {
                self.saveCompletion()
            }
        }
    }
    
    func saveCompletion() {
        if blockId == nil {
            self.paragraphViewModel.setCompletion(completionId: completionId, completionComment: comment)
        }
        
        // Currently ugly, but this is the case where the comment is being made upon the paragraph that is shown in the modal
        if let blockId = blockId, viewModel.document != nil {
            let userInput = AnyUserInput(UserInputCompletion(blockId: blockId, inputType: .completion, completion: [completionId: comment], timestamp: Int(Date().timeIntervalSince1970)))
            viewModel.saveBlockUserInput(
                documentId: viewModel.document?.id,
                blockId: blockId,
                userInputType: .completion,
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
