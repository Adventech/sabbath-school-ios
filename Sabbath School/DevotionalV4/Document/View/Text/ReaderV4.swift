/*
 * Copyright (c) 2023 Adventech <info@adventech.io>
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

import UIKit

enum ContextMenuAction {
    case highlight(color: UIColor)
    case copy(text: String)
    case share(text: String)
}

class ReaderV4: UITextView {
    
    var contextMenuAction: ((ContextMenuAction) -> Void)?
    
    init(contextMenuAction: ((ContextMenuAction) -> Void)?) {
        self.contextMenuAction = contextMenuAction
        super.init(frame: CGRect.zero, textContainer: nil)
        setupContextMenu()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
        case #selector(didTapHighlightGreen),
            #selector(didTapHighlightBlue),
            #selector(didTapHighlightYellow),
            #selector(didTapHighlightOrange),
            #selector(didTapClearHighlight),
            #selector(didTapCopy),
            #selector(didTapShare),
            #selector(paste(_:)):
            return super.canPerformAction(action, withSender: sender)
        default:
            return false
        }
    }
}

// MARK: Private Functions

private extension ReaderV4 {
    
    // MARK: Setup Context Menu
    
    func setupContextMenu() {
        let highlightGreen = UIMenuItem(title: "Green", image: R.image.iconHighlightGreen()) { _ in }
        highlightGreen.action = #selector(didTapHighlightGreen)
        
        let highlightBlue = UIMenuItem(title: "Blue", image: R.image.iconHighlightBlue()) { _ in }
        highlightBlue.action = #selector(didTapHighlightBlue)
        
        let highlightYellow = UIMenuItem(title: "Yellow", image: R.image.iconHighlightYellow()) { _ in }
        highlightYellow.action = #selector(didTapHighlightYellow)
        
        let highlightOrange = UIMenuItem(title: "Orange", image: R.image.iconHighlightOrange()) { _ in }
        highlightOrange.action = #selector(didTapHighlightOrange)
        
        let clearHighlight = UIMenuItem(title: "Clear", image: R.image.iconHighlightClear()) { _ in }
        clearHighlight.action = #selector(didTapClearHighlight)
        
        let copy = UIMenuItem(title: "Copy".localized(), image: nil) { _ in }
        copy.action = #selector(didTapCopy)

        let paste = UIMenuItem(title: "Paste".localized(), image: nil) { _ in }
        paste.action = #selector(paste(_:))
        
        let share = UIMenuItem(title: "Share".localized(), image: nil) { _ in }
        share.action = #selector(didTapShare)

        UIMenuController.shared.menuItems = [highlightGreen, highlightBlue, highlightYellow, highlightOrange, clearHighlight, copy, paste, share]
    }
    
    // MARK: Context Menu Actions
    
    @objc func didTapHighlightGreen() {
        didHighlight(UIColor(hex: "#63D724"), foregroundColor: UIColor.black, selectedRange: selectedRange)
        contextMenuAction?(.highlight(color: UIColor(hex: "#63D724")))
    }
    
    @objc func didTapHighlightBlue() {
        didHighlight(UIColor(hex: "#69D2F5"), foregroundColor: UIColor.black, selectedRange: selectedRange)
        contextMenuAction?(.highlight(color: UIColor(hex: "#69D2F5")))
    }
    
    @objc func didTapHighlightYellow() {
        didHighlight(UIColor(hex: "#FFF3A0"), foregroundColor: UIColor.black, selectedRange: selectedRange)
        contextMenuAction?(.highlight(color: UIColor(hex: "#FFF3A0")))
    }
    
    @objc func didTapHighlightOrange() {
        didHighlight(UIColor(hex: "#F59569"), foregroundColor: UIColor.black, selectedRange: selectedRange)
        contextMenuAction?(.highlight(color: UIColor(hex: "#F59569")))
    }
    
    @objc func didTapClearHighlight() {
        didHighlight(AppStyle.Base.Color.background, foregroundColor: AppStyle.Quarterly.Color.introduction, selectedRange: selectedRange)
    }
    
    @objc func didTapCopy() {
        let text = attributedText.attributedSubstring(from: selectedRange).string
        contextMenuAction?(.copy(text: text))
    }
    
    @objc func didTapShare() {
        let text = attributedText.attributedSubstring(from: selectedRange).string
        contextMenuAction?(.share(text: text))
    }
    
    func didHighlight(_ backgroundColor: UIColor, foregroundColor: UIColor, selectedRange: NSRange) {
        guard let text = attributedText?.mutableCopy() as? NSMutableAttributedString else { return }
        text.addAttribute(.backgroundColor, value: backgroundColor, range: selectedRange)
        text.addAttribute(.foregroundColor, value: foregroundColor, range: selectedRange)
        
        attributedText = text.copy() as? NSAttributedString
    }
}
