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

class ChecklistViewModel: ObservableObject {
    @Published var checked: [Int] = []
    @Published var savingMode: Bool = false
    
    public func loadUserInput(userInput: UserInputChecklist) {
        self.checked = userInput.checked
    }
    
    public func receiveChecklistItemChange(index: Int, checked: Bool) {
        savingMode = true
        if checked {
            if !self.checked.contains(index) {
                self.checked.append(index)
            }
        } else {
            if let position = self.checked.firstIndex(of: index) {
                self.checked.remove(at: position)
            }
        }
    }
    
    public func isChecked(index: Int) -> Bool {
        return self.checked.contains(index)
    }
}

struct BlockChecklistView: StyledBlock, InteractiveBlock, View {
    var block: Checklist
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    
    @EnvironmentObject var viewModel: DocumentViewModel
    @StateObject var checklistViewModel: ChecklistViewModel = ChecklistViewModel()
    
    var body: some View {
        VStack (spacing: 5) {
            ForEach(block.items) { item in
                BlockWrapperView(block: item, parentBlock: AnyBlock(block))
                    .environmentObject(checklistViewModel)
            }
        }
        .onAppear {
            loadInputData()
        }
        .onChange(of: viewModel.documentUserInput) { newValue in
            loadInputData()
        }.onChange(of: checklistViewModel.checked) { newValue in
            if !checklistViewModel.savingMode { return }
            
            saveUserInput(AnyUserInput(UserInputChecklist(blockId: block.id, inputType: .checklist, checked: newValue, timestamp: Int(Date().timeIntervalSince1970))))
        }
    }
    
    internal func loadInputData() {
        if let userInput = getUserInputForBlock(blockId: block.id, userInput: nil)?.asType(UserInputChecklist.self) {
            checklistViewModel.loadUserInput(userInput: userInput)
        }
    }
}

struct BlockChecklistItemView: StyledBlock, View {
    var block: ChecklistItem
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    @EnvironmentObject var themeManager: ThemeManager
    
    @EnvironmentObject var viewModel: ChecklistViewModel
    @State var checked = false
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    checked.toggle()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    viewModel.receiveChecklistItemChange(index: block.index, checked: checked)
                }
            }) {
                HStack(spacing: 0) {
                    VStack {
                        Image(
                            systemName: checked ? "checkmark.circle.fill" : "circle"
                        )
                        .renderingMode(.template)
                        .foregroundColor(AppStyle.Block.Checklist.checkmarkColor())
                        .frame(width: 25)
                    }
                    .frame(maxHeight: .infinity)
                    .padding(10)
                    .background(AppStyle.Block.Checklist.checkmarkBackgroundColor())
                    
                    Divider().frame(width: 1).background(AppStyle.Block.Checklist.borderColor()).padding(0)
                    
                    InlineAttributedText(block: AnyBlock(block), markdown: block.markdown).frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                    
                    Spacer()
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }.overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(AppStyle.Block.Checklist.borderColor(), lineWidth: 2)
        )
        .cornerRadius(6)
        .onChange(of: viewModel.checked) { newValue in
            checked = newValue.contains(block.index)
        }
    }
}

#Preview {
    BlockChecklistView(block:
        Checklist(
            id: "checklist_id",
            type: .checklist,
            style: BlockStyle(block: nil, wrapper: nil, image: nil, text: nil),
            ordered: false,
            start: 0,
            items: [
                AnyBlock(ChecklistItem(
                    id: "checklist_item_id_1",
                    type: .checklistItem,
                    style: BlockStyle(block: nil, wrapper: nil, image: nil, text: nil),
                    index: 0,
                    markdown: "Item 1",
                    data: nil,
                    nested: true)),
                AnyBlock(ChecklistItem(
                    id: "checklist_item_id_2",
                    type: .checklistItem,
                    style: BlockStyle(block: nil, wrapper: nil, image: nil, text: nil),
                    index: 1,
                    markdown: "Item 2",
                    data: nil,
                    nested: true))
            ],
            data: nil,
            nested: false)
    )
    .environmentObject(ThemeManager())
    .environmentObject(DocumentViewModel())
}
