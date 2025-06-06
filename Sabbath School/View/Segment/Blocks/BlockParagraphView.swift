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

class ParagraphViewModel: ObservableObject {
    @Published var highlights: [UserInputHighlight] = []
    @Published var comment: String = ""
    @Published var inlineComments: [UserInputInlineComment] = []
    @Published var underlines: [UserInputUnderline] = []
    @Published var savingMode: Bool = false
    @Published var completion: [String: String] = [:]

    public func loadUserInput(userInput: UserInputHighlights) {
        self.highlights = userInput.highlights
    }
    
    public func loadUserInputUnderlines(userInput: UserInputUnderlines) {
        self.underlines = userInput.underlines
    }
    
    public func loadUserInputInlineComments(userInput: UserInputInlineComments) {
        self.inlineComments = []
        self.inlineComments = userInput.inlineComments
    }
    
    public func loadUserInputComment(userInput: UserInputComment) {
        self.comment = userInput.comment
    }

    public func setHighlight(startIndex: Int, endIndex: Int, length: Int, color: HighlightColor) {
        savingMode = true
        self.highlights.append(UserInputHighlight(startIndex: startIndex, endIndex: endIndex, length: length, color: color))
    }
    
    public func setUnderline(startIndex: Int, endIndex: Int, length: Int, color: HighlightColor) {
        savingMode = true
        self.underlines.append(UserInputUnderline(startIndex: startIndex, endIndex: endIndex, length: length, color: color))
    }
    
    public func setInlineComment(startIndex: Int, endIndex: Int, length: Int, color: HighlightColor, comment: String) {
        savingMode = true
        self.inlineComments.append(UserInputInlineComment(startIndex: startIndex, endIndex: endIndex, length: length, color: color, comment: comment))
    }

    public func removeHighlight(startIndex: Int, endIndex: Int, length: Int) {
        savingMode = true
        let endIndex = startIndex + length
        self.highlights = self.highlights.filter { highlight in
            return (highlight.startIndex + highlight.length <= startIndex) || (highlight.startIndex >= endIndex)
        }
    }
    
    public func removeUnderline(startIndex: Int, endIndex: Int, length: Int) {
        savingMode = true
        let endIndex = startIndex + length
        self.underlines = self.underlines.filter { underline in
            return (underline.startIndex + underline.length <= startIndex) || (underline.startIndex >= endIndex)
        }
    }

    public func setComment(comment: String) {
        savingMode = true
        self.comment = comment
    }
    
    public func loadUserInputCompletion(userInput: UserInputCompletion) {
        self.completion = userInput.completion
    }
    
    public func setCompletion(completionId: String, completionComment: String) {
        savingMode = true
        self.completion[completionId] = completionComment
    }
}

struct BlockParagraphView: StyledBlock, View {
    var block: Paragraph
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    
    @State var parentBlock: AnyBlock?
    
    var body: some View {
        let alignment = Styler.getTextAlignment(defaultStyles, BlockStyleTemplate(), AnyBlock(block))
        
        InlineAttributedText(
            block: AnyBlock(block),
            markdown: block.markdown,
            selectable: isSelectable()
        )
        .frame(maxWidth: .infinity, alignment: BlockParagraphView.convertTextAlignment(alignment))
    }
    
    private func isSelectable() -> Bool {
        guard let parent = parentBlock else {
            return true
        }
        
        // Making sure that we only allow selecting if the paragraph immediate child of these block types
        switch parent.type {
        case .collapse:
            return true
        case .blockquote:
            return true
        case .listItem:
            return true
        case .excerptItem:
            return true
        case .table:
            return true
        default:
            return false
        }
    }
    
    public static func convertTextAlignment(_ textAlignment: TextAlignment) -> Alignment {
        switch textAlignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }
}
