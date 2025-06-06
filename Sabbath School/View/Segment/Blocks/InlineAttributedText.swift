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
import SafariServices
import SwiftEntryKit
import Combine

class LayoutAwareTextViewController: ObservableObject {
    var getPositionsForInlineComments: (([UserInputInlineComment]) -> Void)?

    func getPositionsForInlineComments(inlineComments: [UserInputInlineComment]) {
        getPositionsForInlineComments?(inlineComments)
    }
}

class LayoutAwareTextView: UITextView {
    var onFullyLaidOut: (() -> Void)?
    public var didLayout = false
    public var counter = 0

    override func layoutSubviews() {
        super.layoutSubviews()

        guard !didLayout && counter < 5 else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.didLayout = true
            self.counter += 1
            self.onFullyLaidOut?()
        }
    }

    func resetLayoutFlag() {
        didLayout = false
    }
}

struct InlineTextViewWrapper: UIViewRepresentable {
    @ObservedObject var controller: LayoutAwareTextViewController
    var attributedString: AttributedString
    @Binding var height: CGFloat
    @ObservedObject var paragraphViewModel: ParagraphViewModel
    var onLinkClick: ((URL) -> Void)?
    var onHighlight: ((NSRange, HighlightColor) -> Void)?
    var onUnderline: ((NSRange, HighlightColor) -> Void)?
    var onRemoveHighlight: ((NSRange) -> Void)?
    var onRemoveUnderline: ((NSRange) -> Void)?
    var onComment: (() -> Void)?
    var onInlineComment: ((NSRange, UserInputInlineComment?) -> Void)?
    var onPosition: (([IconPosition]) -> Void)?
    var alignment: TextAlignment
    var cachedPositions: [IconPosition] = []
    
    func makeUIView(context: Context) -> LayoutAwareTextView {
        let textView = LayoutAwareTextView()
        textView.isEditable = false
        textView.isSelectable = true
        
        textView.dataDetectorTypes = []
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.textColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.adjustsFontForContentSizeCategory = true
        textView.textContainer.widthTracksTextView = true
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.accessibilityElementsHidden = true

        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.clear]
        
        context.coordinator.textView = textView

        controller.getPositionsForInlineComments = { inlineComments in
            DispatchQueue.main.async {
                textView.counter = 0
                textView.didLayout = false
                calculateThePositionOfTheInlineCommentIcons(textView: textView, inlineComments: inlineComments)
            }
        }
        
        textView.onFullyLaidOut = {
            calculateThePositionOfTheInlineCommentIcons(textView: textView, inlineComments: paragraphViewModel.inlineComments)
        }
        
        return textView
    }
    
    func updateUIView(_ textView: LayoutAwareTextView, context: Context) {
        textView.resetLayoutFlag()
        
        let attributedText = NSMutableAttributedString(attributedString)
        
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.clear]
        
                
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        switch alignment {
        case .leading:
            paragraphStyle.alignment = .left
        case .trailing:
            paragraphStyle.alignment = .right
        case .center:
            paragraphStyle.alignment = .center
        }
        
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.characters.count))
        attributedText.addAttributes(attributes, range: NSRange(location: 0, length: attributedString.characters.count))
        attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length), options: []) { attributes, range, stop in
            var newAttributes = attributes
            newAttributes[.foregroundColor] = UIColor.clear
            attributedText.setAttributes(newAttributes, range: range)
        }
        
        DispatchQueue.main.async {
            textView.attributedText = attributedText
        }
        
        textView.sizeToFit()
        
        DispatchQueue.main.async {
            self.height = textView.contentSize.height
        }
    }
    
    func calculateThePositionOfTheInlineCommentIcons(textView: LayoutAwareTextView, inlineComments: [UserInputInlineComment]) {
        var positions: [IconPosition] = []
        for inlineComment in inlineComments {
            let layoutManager = textView.layoutManager
            let textContainer = textView.textContainer
            

            let glyphRange = layoutManager.glyphRange(forCharacterRange: NSRange(location: inlineComment.startIndex, length: inlineComment.length), actualCharacterRange: nil)
            let rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            let x = rect.maxX + 7
            let y = rect.minY
            if !x.isInfinite && !y.isInfinite {
                positions.append(IconPosition(x: x, y: y, inlineComment: inlineComment))
            }
            
        }
        self.onPosition?(positions)
    }
    

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: InlineTextViewWrapper
        weak var textView: UITextView?

        init(_ parent: InlineTextViewWrapper) {
            self.parent = parent
        }
        
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            parent.onLinkClick?(URL)
            return false
        }
        
        
        func textView(_ textView: UITextView, editMenuForTextIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
            let highlightBlue = UIAction(title: "", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor(AppStyle.Block.highlightBlue), renderingMode: .alwaysOriginal)) { action in
                self.parent.onHighlight?(range, .blue)
                self.clearSelection(textView)
            }
            
            let highlightGreen = UIAction(title: "", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor(AppStyle.Block.highlightGreen), renderingMode: .alwaysOriginal)) { action in
                self.parent.onHighlight?(range, .green)
                self.clearSelection(textView)
            }
            
            let highlightOrange = UIAction(title: "", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor(AppStyle.Block.highlightOrange), renderingMode: .alwaysOriginal)) { action in
                self.parent.onHighlight?(range, .orange)
                self.clearSelection(textView)
            }

            let highlightYellow = UIAction(title: "", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor(AppStyle.Block.highlightYellow), renderingMode: .alwaysOriginal)) { action in
                self.parent.onHighlight?(range, .yellow)
                self.clearSelection(textView)
            }
            
            let highlightPurple = UIAction(title: "", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor(AppStyle.Block.highlightPurple), renderingMode: .alwaysOriginal)) { action in
                self.parent.onHighlight?(range, .purple)
                self.clearSelection(textView)
            }
            
            let highlightBrown = UIAction(title: "", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor(AppStyle.Block.highlightBrown), renderingMode: .alwaysOriginal)) { action in
                self.parent.onHighlight?(range, .brown)
                self.clearSelection(textView)
            }
            
            let highlightRed = UIAction(title: "", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor(AppStyle.Block.highlightRed), renderingMode: .alwaysOriginal)) { action in
                self.parent.onHighlight?(range, .red)
                self.clearSelection(textView)
            }
            
            let removeHighlight = UIAction(title: "", image: UIImage(systemName: "x.circle.fill")) { action in
                self.parent.onRemoveHighlight?(range)
                self.clearSelection(textView)
            }
            
            let underlineBlue = UIAction(title: "", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor(AppStyle.Block.highlightBlue), renderingMode: .alwaysOriginal)) { action in
                self.parent.onUnderline?(range, .blue)
                self.clearSelection(textView)
            }
            
            let underlineGreen = UIAction(title: "", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor(AppStyle.Block.highlightGreen), renderingMode: .alwaysOriginal)) { action in
                self.parent.onUnderline?(range, .green)
                self.clearSelection(textView)
            }
            
            let underlineOrange = UIAction(title: "", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor(AppStyle.Block.highlightOrange), renderingMode: .alwaysOriginal)) { action in
                self.parent.onUnderline?(range, .orange)
                self.clearSelection(textView)
            }

            let underlineYellow = UIAction(title: "", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor(AppStyle.Block.highlightYellow), renderingMode: .alwaysOriginal)) { action in
                self.parent.onUnderline?(range, .yellow)
                self.clearSelection(textView)
            }
            
            let underlinePurple = UIAction(title: "", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor(AppStyle.Block.highlightPurple), renderingMode: .alwaysOriginal)) { action in
                self.parent.onUnderline?(range, .purple)
                self.clearSelection(textView)
            }
            
            let underlineBrown = UIAction(title: "", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor(AppStyle.Block.highlightBrown), renderingMode: .alwaysOriginal)) { action in
                self.parent.onUnderline?(range, .brown)
                self.clearSelection(textView)
            }
            
            let underlineRed = UIAction(title: "", image: UIImage(systemName: "circle.fill")?.withTintColor(UIColor(AppStyle.Block.highlightRed), renderingMode: .alwaysOriginal)) { action in
                self.parent.onUnderline?(range, .red)
                self.clearSelection(textView)
            }
            
            let removeUnderline = UIAction(title: "", image: UIImage(systemName: "x.circle.fill")) { action in
                self.parent.onRemoveUnderline?(range)
                self.clearSelection(textView)
            }
            
            let comment = UIAction(title: "", image: UIImage(systemName: "text.bubble")) { action in
                self.parent.onInlineComment?(range, nil)
                self.clearSelection(textView)
            }
            
            let highlightMenu = UIMenu(title: "", image: UIImage(systemName: "highlighter"), children: [highlightBlue, highlightGreen, highlightOrange, highlightYellow, highlightPurple, highlightBrown, highlightRed, removeHighlight])
            
            let underlineMenu = UIMenu(title: "", image: UIImage(systemName: "underline"), children: [underlineBlue, underlineGreen, underlineOrange, underlineYellow, underlinePurple, underlineBrown, underlineRed, removeUnderline])

            return UIMenu(title: "", children: [highlightMenu, underlineMenu, comment] + suggestedActions)
        }
        
        func clearSelection(_ textView: UITextView) {
            textView.selectedRange = NSRange(location: 0, length: 0)
        }
    

        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.height = textView.contentSize.height
            }
        }
        
        func textViewDidLayoutSubviews(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.height = textView.contentSize.height
            }
        }
    }
}

struct IconPosition: Hashable, Identifiable {
    var id = UUID()
    var x: CGFloat
    var y: CGFloat
    var inlineComment: UserInputInlineComment
}

struct InlineAttributedText: StyledBlock, InteractiveBlock, View {
    var block: AnyBlock
    @State var markdown: String
    var originalMarkdown: String
    var selectable: Bool = false
    var lineLimit: Int? = nil
    var headingDepth: HeadingDepth? = nil
    var styleTemplate: StyleTemplate? = nil
    var urlsEnabled: Bool = true
    var startFrom: Int = 0
    
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.openURL) private var openURL
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    @EnvironmentObject var themeManager: ThemeManager
    
    @StateObject private var paragraphViewModel: ParagraphViewModel = ParagraphViewModel()
    
    @EnvironmentObject var viewModel: DocumentViewModel
    
    @State private var height: CGFloat = .zero
    @State private var width: CGFloat = .zero
    @State private var attributedString: AttributedString = AttributedString("")
    @State private var attributedStringWithoutHighlights: AttributedString = AttributedString("")
    
    @State private var initialized = false
    @State private var positions: [IconPosition] = []
    @State private var controller = LayoutAwareTextViewController()
    
    init (block: AnyBlock, markdown: String, selectable: Bool = false, lineLimit: Int? = nil, headingDepth: HeadingDepth? = nil, styleTemplate: StyleTemplate? = nil, urlsEnabled: Bool = true, startFrom: Int = 0) {
        self.block = block
        self.markdown = markdown
        self.originalMarkdown = markdown
        self.selectable = selectable
        self.lineLimit = lineLimit
        self.headingDepth = headingDepth
        self.styleTemplate = styleTemplate
        self.urlsEnabled = urlsEnabled
        self.startFrom = startFrom
    }
    
    var body: some View {
        let alignment = Styler.getTextAlignment(defaultStyles, BlockStyleTemplate(), block)
        
        return VStack {
            ZStack(alignment: .topLeading) {
                Text(attributedString)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(5)
                        .textSelection(.enabled)
                        .overlay(selectable ? overlaySelectableText(attributedString: attributedStringWithoutHighlights, alignment: alignment) : nil, alignment: .top)
                        .multilineTextAlignment(alignment)
                        .lineLimit(lineLimit)
                        .foregroundColor(.white)
                        .environment(\.openURL, OpenURLAction { url in
                            handleURL(url: url)
                            return .handled
                        }).task {
                            if !initialized {
                                initializeText()
                            }
                            
                            loadInputData()
                        }
                        .onChange(of: themeManager.currentTheme) { newValue in
                            initializeText()
                        }
                        .onChange(of: themeManager.currentSize) { newValue in
                            initializeText()
                        }
                        .onChange(of: themeManager.currentTypeface) { newValue in
                            initializeText()
                        }
                        .onChange(of: colorScheme) { newValue in
                            initializeText()
                        }
                        .onChange(of: sizeCategory) { newValue in
                            initializeText()
                        }
                        .onChange(of: viewModel.documentUserInput) { newValue in
                            loadInputData()
                        }
                        .onChange(of: paragraphViewModel.highlights) { newValue in
                            setHighlights(highlights: newValue, inlineComments: paragraphViewModel.inlineComments, underlines: paragraphViewModel.underlines)
                            
                            if !paragraphViewModel.savingMode { return }
                            
                            saveUserInput(AnyUserInput(UserInputHighlights(blockId: block.id, inputType: .highlights, highlights: newValue, timestamp: Int(Date().timeIntervalSince1970))))
                        }
                        .onChange(of: paragraphViewModel.underlines) { newValue in
                            setHighlights(highlights: paragraphViewModel.highlights, inlineComments: paragraphViewModel.inlineComments, underlines: newValue)
                            
                            if !paragraphViewModel.savingMode { return }
                            
                            saveUserInput(AnyUserInput(UserInputUnderlines(blockId: block.id, inputType: .underlines, underlines: newValue, timestamp: Int(Date().timeIntervalSince1970))))
                        }
                        .onChange(of: paragraphViewModel.inlineComments) { newValue in
                            setHighlights(highlights: paragraphViewModel.highlights, inlineComments: newValue, underlines: paragraphViewModel.underlines)

                            if !paragraphViewModel.savingMode { return }

                            saveUserInput(AnyUserInput(UserInputInlineComments(blockId: block.id, inputType: .inlineComments, inlineComments: newValue, timestamp: Int(Date().timeIntervalSince1970))))
                        }
                        .onChange(of: paragraphViewModel.comment) { newValue in
                            if !paragraphViewModel.savingMode { return }
                            
                            saveUserInput(AnyUserInput(UserInputComment(blockId: block.id, inputType: .comment, comment: newValue, timestamp: Int(Date().timeIntervalSince1970))))
                        }
                        .onChange(of: paragraphViewModel.completion) { newValue in
                            initializeText(newValue)
                            
                            if !paragraphViewModel.savingMode { return }
                            
                            saveUserInput(AnyUserInput(UserInputCompletion(blockId: block.id, inputType: .completion, completion: newValue, timestamp: Int(Date().timeIntervalSince1970))))
                        }
                
                if !paragraphViewModel.comment.isEmpty && selectable {
                    VStack(alignment: .trailing) {
                        Button (action: {
                            onComment()
                        }) {
                            Image(systemName: "text.bubble")
                                .foregroundColor(Color(uiColor: .baseGray2))
                                .imageScale(.medium)
                        }
                        .offset(y: -15)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                ForEach(positions) { position in
                    VStack(alignment: .leading) {
                        Button (action: {
                            onInlineComment(
                                range: NSRange(location: position.inlineComment.startIndex, length: position.inlineComment.length),
                                inlineComment: position.inlineComment
                            )
                        }) {
                            Image(systemName: "text.bubble")
                                .foregroundColor(themeManager.getTextColor() | .white)
                                .imageScale(.small)
                        }
                        .frame(width: 14, height: 14)
                        .frame(maxWidth: 14, maxHeight: 14)
                        .position(x: position.x, y: position.y)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(0)
        }.padding(0)
    }
    
    internal func initializeText(_ completion: [String: String]? = nil) {
        var template = BlockStyleTemplate()
        
        if let headingDepth = headingDepth {
            template = HeadingStyleTemplate(depth: headingDepth)
        }
        
        updateMarkdownWithCompletions(completion ?? paragraphViewModel.completion)
        
        attributedString = AppStyle.Block.text(markdown, defaultStyles, block, styleTemplate ?? template)
        attributedStringWithoutHighlights = attributedString
        initialized = true
        setHighlights(highlights: paragraphViewModel.highlights, inlineComments: paragraphViewModel.inlineComments, underlines: paragraphViewModel.underlines)
        controller.getPositionsForInlineComments(inlineComments: paragraphViewModel.inlineComments)
    }
    
    internal func updateMarkdownWithCompletions(_ completion: [String: String]) {
        if !completion.isEmpty {
            self.markdown = originalMarkdown
            for (completionId, completionComment) in completion {
                self.markdown = fillCompletionText(in: markdown, completionId: completionId, completionComment: completionComment, correctAnswer: block.data?.completion?[completionId]?.correctCompletion ?? nil)
            }
        }
    }
    
    func fillCompletionText(in originalString: String, completionId: String, completionComment: String, correctAnswer: String? = nil) -> String {
        let regex = "\\[⠀+\\](\\(sspmCompletion://\(completionId)\\))"
        
        if completionComment.isEmpty  {
            return originalString
        }
        
        var replacement = completionComment.isEmpty ? String(repeating: "⠀", count: 10) : completionComment
        
        if let correctAnswer = correctAnswer, !completionComment.isEmpty {
            replacement = "\(replacement) \(completionComment.caseInsensitiveCompare(correctAnswer) == .orderedSame ? "✓" : "𐄂")"
        }
        
        let repl = "[\(replacement)]$1"
        return originalString.replacingOccurrences(of: regex, with: repl, options: [.regularExpression])
    }
    
    internal func loadInputData() {
        if let userInput = viewModel.documentUserInput.first(where: { $0.blockId == block.id && $0.inputType == .highlights })?.asType(UserInputHighlights.self) {
            paragraphViewModel.loadUserInput(userInput: userInput)
        }
        
        if let userInputUnderlines = viewModel.documentUserInput.first(where: { $0.blockId == block.id && $0.inputType == .underlines })?.asType(UserInputUnderlines.self) {
            paragraphViewModel.loadUserInputUnderlines(userInput: userInputUnderlines)
        }
        
        if let userInputInlineComments = viewModel.documentUserInput.first(where: { $0.blockId == block.id && $0.inputType == .inlineComments })?.asType(UserInputInlineComments.self) {
            paragraphViewModel.loadUserInputInlineComments(userInput: userInputInlineComments)
            controller.getPositionsForInlineComments(inlineComments: userInputInlineComments.inlineComments)
        }
        
        // TODO: refactor so that getUserInputForBlock can support multiple userinputs for the same block but different type
        if let userInputComment = viewModel.documentUserInput.first(where: { $0.blockId == block.id && $0.inputType == .comment })?.asType(UserInputComment.self) {
            paragraphViewModel.loadUserInputComment(userInput: userInputComment)
        }
        
        // TODO: refactor so that getUserInputForBlock can support multiple userinputs for the same block but different type
        if let userInputCompletion = viewModel.documentUserInput.first(where: { $0.blockId == block.id && $0.inputType == .completion })?.asType(UserInputCompletion.self) {
            paragraphViewModel.loadUserInputCompletion(userInput: userInputCompletion)
        }
    }
    
    private func setHighlights(highlights: [UserInputHighlight], inlineComments: [UserInputInlineComment], underlines: [UserInputUnderline]) {
        attributedString = attributedStringWithoutHighlights
        
        for highlight in highlights {
            let range = NSRange(location: highlight.startIndex, length: highlight.length)
            var backgroundColor: Color
            if let range = Range(range, in: attributedString) {
                switch highlight.color {
                case .yellow:
                    backgroundColor = AppStyle.Block.highlightYellow
                case .blue:
                    backgroundColor = AppStyle.Block.highlightBlue
                case .orange:
                    backgroundColor = AppStyle.Block.highlightOrange
                case .green:
                    backgroundColor = AppStyle.Block.highlightGreen
                case .purple:
                    backgroundColor = AppStyle.Block.highlightPurple
                case .brown:
                    backgroundColor = AppStyle.Block.highlightBrown
                case .red:
                    backgroundColor = AppStyle.Block.highlightRed
                }
                
                attributedString[range].backgroundColor = backgroundColor
                attributedString[range].foregroundColor = AppStyle.Block.highlightForeground

            }
        }
        
        for inlineComment in inlineComments {
            let range = NSRange(location: inlineComment.startIndex, length: inlineComment.length)
            var backgroundColor: Color
            if let range = Range(range, in: attributedString) {
                switch inlineComment.color {
                case .yellow:
                    backgroundColor = AppStyle.Block.highlightYellow
                case .blue:
                    backgroundColor = AppStyle.Block.highlightBlue
                case .orange:
                    backgroundColor = AppStyle.Block.highlightOrange
                case .green:
                    backgroundColor = AppStyle.Block.highlightGreen
                case .purple:
                    backgroundColor = AppStyle.Block.highlightPurple
                case .brown:
                    backgroundColor = AppStyle.Block.highlightBrown
                case .red:
                    backgroundColor = AppStyle.Block.highlightRed
                }
                
                attributedString[range].backgroundColor = backgroundColor
                attributedString[range].foregroundColor = AppStyle.Block.highlightForeground
            }
        }
        
        for underline in underlines {
            let range = NSRange(location: underline.startIndex, length: underline.length)
            var backgroundColor: Color
            if let range = Range(range, in: attributedString) {
                switch underline.color {
                case .yellow:
                    backgroundColor = AppStyle.Block.highlightYellow
                case .blue:
                    backgroundColor = AppStyle.Block.highlightBlue
                case .orange:
                    backgroundColor = AppStyle.Block.highlightOrange
                case .green:
                    backgroundColor = AppStyle.Block.highlightGreen
                case .purple:
                    backgroundColor = AppStyle.Block.highlightPurple
                case .brown:
                    backgroundColor = AppStyle.Block.highlightBrown
                case .red:
                    backgroundColor = AppStyle.Block.highlightRed
                }
                
                
                attributedString[range].underlineStyle = Text.LineStyle(pattern: .solid, color: backgroundColor)
            }
        }
        self.trimTextIfNeeded()
    }
    
    func trimTextIfNeeded() {
        if startFrom > 0 {
            if let startIndex = attributedString.characters.index(attributedString.startIndex, offsetBy: startFrom, limitedBy: attributedString.endIndex) {
                let substring = AttributedString(attributedString[startIndex..<attributedString.endIndex])
                attributedString = substring
            }
        }
    }
    
    @ViewBuilder
    func overlaySelectableText(attributedString: AttributedString, alignment: TextAlignment) -> some View {
        InlineTextViewWrapper(
            controller: controller,
            attributedString: attributedStringWithoutHighlights,
            height: $height,
            paragraphViewModel: paragraphViewModel,
            onLinkClick: handleURL,
            onHighlight: onHighlight,
            onUnderline: onUnderline,
            onRemoveHighlight: onRemoveHighlight,
            onRemoveUnderline: onRemoveUnderline,
            onComment: onComment,
            onInlineComment: onInlineComment,
            onPosition: onPosition,
            alignment: alignment
        )
        .frame(height: height, alignment: .leading)
        .padding(0)
    }
    
    private func handleURL(url: URL) {
        if !urlsEnabled { return }
        if let data = block.data,
           let host = url.host,
           let bible = data.bible?[host],
           url.absoluteString.contains("sspmBible") {
            self.showBibleModal(bible: bible)
        } else if let data = block.data,
                  let host = url.host,
                  let paragraphs = data.egw?[host],
                  url.absoluteString.contains("sspmEGW") {
            
            self.showEGWModal(paragraphs: paragraphs)
        } else if
            let data = block.data,
            let host = url.host,
            let completion = data.completion?[host],
            url.absoluteString.contains("sspmCompletion") {
            
            showCompletionModal(completionId: host, completion: completion)
        } else {
            openURL(url)
        }
    }
    
    private func onPosition(positions: [IconPosition]) {
        DispatchQueue.main.async {
            if self.positions.count > 0 && positions.count == 0 {
                return
            }
            self.positions = positions
        }
    }
    
    private func onHighlight(range: NSRange, color: HighlightColor) {
        paragraphViewModel.setHighlight(startIndex: range.location, endIndex: range.location + range.length, length: range.length, color: color)
    }
    
    private func onUnderline(range: NSRange, color: HighlightColor) {
        paragraphViewModel.setUnderline(startIndex: range.location, endIndex: range.location + range.length, length: range.length, color: color)
    }
    
    private func onInlineComment(range: NSRange, inlineComment: UserInputInlineComment? = nil) {
        let hostingController = UIHostingController(
            rootView: ResourceInlineCommentView(
                comment: inlineComment?.comment ?? "",
                block: block,
                markdown: markdown,
                blockId: SwiftEntryKit.isCurrentlyDisplaying ? block.id : nil,
                startIndex: range.location,
                endIndex: range.location + range.length,
                length: range.length,
                inlineComment: inlineComment)
                .environmentObject(viewModel)
                .environmentObject(paragraphViewModel)
                .environmentObject(themeManager)
                .environment(\.defaultBlockStyles, defaultStyles)
        )
        hostingController.view.layer.cornerRadius = 6
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        var attrs = Animation.modalAnimationAttributes(widthRatio: 0.9, heightRatio: 0.6, backgroundColor: UIColor(themeManager.getBackgroundColor()), hasKeyboard: true)
    
        
        if let currentBibleBlock = ModalManager.shared.currentBibleBlock, SwiftEntryKit.isCurrentlyDisplaying {
            attrs.lifecycleEvents.didDisappear = {
                self.showBibleModal(bible: currentBibleBlock)
            }
        } else if let currentEGWBlock = ModalManager.shared.currentEGWBlock, SwiftEntryKit.isCurrentlyDisplaying {
            attrs.lifecycleEvents.didDisappear = {
                self.showEGWModal(paragraphs: currentEGWBlock)
            }
        }
        
        SwiftEntryKit.display(entry: hostingController, using: attrs)
    }
    
    private func onRemoveHighlight(range: NSRange) {
        paragraphViewModel.removeHighlight(startIndex: range.location, endIndex: range.location + range.length, length: range.length)
    }
    
    private func onRemoveUnderline(range: NSRange) {
        paragraphViewModel.removeUnderline(startIndex: range.location, endIndex: range.location + range.length, length: range.length)
    }
    
    private func showBibleModal(bible: Excerpt) {
        ModalManager.shared.currentBibleBlock = bible
        ModalManager.shared.currentEGWBlock = nil
        
        let bibleViewController = UIHostingController(
            rootView: ResourceBibleView(block: bible)
                .environmentObject(viewModel)
                .environmentObject(themeManager)
                .environmentObject(paragraphViewModel)
        )
        bibleViewController.view.layer.cornerRadius = 6
        
        let attrs = Animation.modalAnimationAttributes(widthRatio: 0.9, heightRatio: 0.8, backgroundColor: UIColor(themeManager.getBackgroundColor()))
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        SwiftEntryKit.display(entry: bibleViewController, using: attrs)
    }
    
    private func showEGWModal(paragraphs: [AnyBlock]) {
        ModalManager.shared.currentBibleBlock = nil
        ModalManager.shared.currentEGWBlock = paragraphs
        
        let hostingController = UIHostingController(
            rootView: ResourceEGWView(paragraphs: paragraphs)
                .environmentObject(viewModel)
                .environmentObject(themeManager)
                .environmentObject(paragraphViewModel)
        )
        hostingController.view.layer.cornerRadius = 6
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        SwiftEntryKit.display(entry: hostingController, using: Animation.modalAnimationAttributes(widthRatio: 0.9, heightRatio: 0.8, backgroundColor: UIColor(themeManager.backgroundColor)))
    }
    
    private func showCompletionModal(completionId: String, completion: CompletionData) {
        let hostingController = UIHostingController(
            rootView: ResourceCompletionView(
                completionId: completionId,
                completion: completion,
                block: block,
                blockId: SwiftEntryKit.isCurrentlyDisplaying ? block.id : nil,
                comment: paragraphViewModel.completion[completionId] ?? "")
                .environmentObject(viewModel)
                .environmentObject(paragraphViewModel)
                .environmentObject(themeManager)
        )
        hostingController.view.layer.cornerRadius = 6
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        var attrs = Animation.modalAnimationAttributes(widthRatio: 0.9, heightRatio: 0.4, backgroundColor: UIColor(themeManager.getBackgroundColor()), hasKeyboard: true)
    
        
        if let currentBibleBlock = ModalManager.shared.currentBibleBlock, SwiftEntryKit.isCurrentlyDisplaying {
            attrs.lifecycleEvents.didDisappear = {
                self.showBibleModal(bible: currentBibleBlock)
            }
        } else if let currentEGWBlock = ModalManager.shared.currentEGWBlock, SwiftEntryKit.isCurrentlyDisplaying {
            attrs.lifecycleEvents.didDisappear = {
                self.showEGWModal(paragraphs: currentEGWBlock)
            }
        }
        
        SwiftEntryKit.display(entry: hostingController, using: attrs)
    }
    
    private func onComment() {
        let hostingController = UIHostingController(
            rootView: ResourceCommentView(
                comment: paragraphViewModel.comment,
                block: block,
                markdown: markdown,
                blockId: SwiftEntryKit.isCurrentlyDisplaying ? block.id : nil)
                .environmentObject(viewModel)
                .environmentObject(paragraphViewModel)
                .environmentObject(themeManager)
                .environment(\.defaultBlockStyles, defaultStyles)
        )
        hostingController.view.layer.cornerRadius = 6
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        var attrs = Animation.modalAnimationAttributes(widthRatio: 0.9, heightRatio: 0.4, backgroundColor: UIColor(themeManager.getBackgroundColor()), hasKeyboard: true)
    
        
        if let currentBibleBlock = ModalManager.shared.currentBibleBlock, SwiftEntryKit.isCurrentlyDisplaying {
            attrs.lifecycleEvents.didDisappear = {
                self.showBibleModal(bible: currentBibleBlock)
            }
        } else if let currentEGWBlock = ModalManager.shared.currentEGWBlock, SwiftEntryKit.isCurrentlyDisplaying {
            attrs.lifecycleEvents.didDisappear = {
                self.showEGWModal(paragraphs: currentEGWBlock)
            }
        }
        
        SwiftEntryKit.display(entry: hostingController, using: attrs)
    }
}

class ModalManager {
    static let shared = ModalManager()

    var currentBibleBlock: Excerpt? = nil
    var currentEGWBlock: [AnyBlock]? = nil

    private init() { }
}
