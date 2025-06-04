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

struct BlockAppealView: StyledBlock, InteractiveBlock, View {
    var block: Appeal
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    @EnvironmentObject var themeManager: ThemeManager
    
    @EnvironmentObject var viewModel: DocumentViewModel
    
    @State var checked = false
    
    var body: some View {
        VStack(spacing: 10) {
            Text(AppStyle.Block.text(block.markdown, defaultStyles, AnyBlock(block), AppealStyleTemplate()))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Button(action: {
                checked.toggle()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                self.saveUserInput(AnyUserInput(UserInputAppeal(blockId: block.id, inputType: .appeal, appeal: checked, timestamp: Int(Date().timeIntervalSince1970))))
            }) {
                Image(systemName: checked ? "checkmark.square.fill" : "square")
                    .font(.largeTitle)
                    .foregroundColor(themeManager.getSecondaryTextColor())
                    .animation(.easeInOut(duration: 0.3), value: checked)
            }.onAppear {
                loadInputData()
            }.onChange(of: viewModel.documentUserInput) { newValue in
                loadInputData()
            }
        }
        .padding(20)
        .background(themeManager.getSecondaryBackgroundColor())
        .cornerRadius(6)
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    internal func loadInputData() {
        self.checked = getUserInputForBlock(blockId: block.id, userInput: nil)?.asType(UserInputAppeal.self)?.appeal ?? false
    }
}

#Preview {
    BlockAppealView(block: Appeal(id: "appeal_id", type: .appeal, style: BlockStyle(block: nil, wrapper: nil, image: nil, text: nil), data: nil, markdown: "Would you consider this?", nested: false))
        .environmentObject(ThemeManager())
        .environmentObject(DocumentViewModel())
}
