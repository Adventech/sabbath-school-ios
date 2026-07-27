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

struct BlockQuestionView: StyledBlock, InteractiveBlock, View {
    var block: Question
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var viewModel: DocumentViewModel
    
    @State var answer: String = ""
    @StateObject private var pendingSave = PendingUserInputSave()
    let delay: TimeInterval = 1.0
    
    var body: some View {
        VStack (spacing: 0) {
            VStack (spacing: 0) {
                if !block.markdown.isEmpty {
                    InlineAttributedText(
                        block: AnyBlock(block),
                        markdown: block.markdown,
                        selectable: true
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                }
            }
            .padding(0)
            .background(AppStyle.Block.genericBackgroundColorForInteractiveBlock(theme: themeManager.currentTheme))
            
            VStack (spacing: 0) {
                ZStack {
                    Text(answer)
                        .padding(.leading, 50)
                        .padding(.vertical, 0)
                        .opacity(0)
                        .font(Font.custom("Lato-Regular", size: BlockStyleTemplate().textSizePoints(.base)))
                        .frame(maxHeight: 600)
                    
                    TextEditor(text: $answer)
                        .onChange(of: answer) { newValue in
                            scheduleAnswerSave(newValue)
                        }
                        .frame(minHeight: 100, alignment: .leading)
                        .frame(maxHeight: 600)
                        .lineLimit(5)
                        .font(Font.custom("Lato-Regular", size: BlockStyleTemplate().textSizePoints(.base)))
                        .foregroundColor(themeManager.getTextColor())
                        .scrollContentBackground(.hidden)
                        .padding(.leading, 50)
                        .padding(.vertical, 0)
                        .overlay {
                            HStack(spacing: 0) {
                                Divider().background(.red)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 40)
                        }
                        .background {
                            VStack {
                                Image("question-line")
                                    .resizable(resizingMode: .tile)
                                    .colorMultiply(.gray.opacity(0.2))
                            }.padding(0)
                        }
                }
            }
            .padding(0)
            .background(AppStyle.Block.Question.answerBackgroundColor(theme: themeManager.currentTheme))
            .frame(alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cornerRadius(6)
        .padding(.vertical, 10)
        .onAppear {
            loadInputData()
        }
        .onChange(of: viewModel.documentUserInput) { newValue in
            loadInputData()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase != .active {
                flushPendingSave()
            }
        }
        .onDisappear {
            flushPendingSave()
        }
        .shadow(color: AppStyle.Block.genericBackgroundColorForInteractiveBlock(theme: themeManager.currentTheme), radius: 5)
    }
    
    func scheduleAnswerSave(_ answer: String) {
        let documentId = viewModel.document?.id
        let blockId = block.id
        let documentViewModel = viewModel

        pendingSave.schedule(after: delay) {
            let userInput = AnyUserInput(UserInputQuestion(
                blockId: blockId,
                inputType: .question,
                answer: answer,
                timestamp: Int(Date().timeIntervalSince1970)
            ))
            documentViewModel.saveBlockUserInput(
                documentId: documentId,
                blockId: blockId,
                userInputType: .question,
                userInput: userInput
            )
        }
    }

    func flushPendingSave() {
        pendingSave.flush()
    }
    
    internal func loadInputData() {
        guard !pendingSave.hasPendingSave else {
            return
        }

        if let newAnswer = getUserInputForBlock(blockId: block.id, userInput: nil)?.asType(UserInputQuestion.self)?.answer {
            if newAnswer != answer {
                self.answer = newAnswer
            }
        }
    }
}

#Preview {
    BlockQuestionView(block:
       Question(
        id: "question_id",
        type: .question,
        style: BlockStyle(block: nil, wrapper: nil, image: nil, text: nil),
        markdown: "Question",
        data: nil,
        nested: false)
    )
    .environmentObject(ThemeManager())
    .environmentObject(DocumentViewModel())
}

