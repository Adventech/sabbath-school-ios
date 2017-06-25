/*
 * Copyright (c) 2017 Adventech <info@adventech.io>
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

import MenuItemKit
import UIKit

struct ReaderStyle {
    struct Theme {
        static var Light: String {
            return "light"
        }
        
        static var Sepia: String {
            return "sepia"
        }
        
        static var Dark: String {
            return "dark"
        }
    }
    
    struct Typeface {
        static var Andada: String {
            return "andada"
        }
        
        static var Lato: String {
            return "lato"
        }
        
        static var PTSerif: String {
            return "pt-serif"
        }
        
        static var PTSans: String {
            return "pt-sans"
        }
    }
    
    struct Size {
        static var Tiny: String {
            return "tiny"
        }
        
        static var Small: String {
            return "small"
        }
        
        static var Medium: String {
            return "medium"
        }
        
        static var Large: String {
            return "large"
        }
        
        static var Huge: String {
            return "huge"
        }
    }
    
    struct Highlight {
        static var Green: String {
            return "green"
        }
        
        static var Blue: String {
            return "blue"
        }
        
        static var Orange: String {
            return "orange"
        }
        
        static var Yellow: String {
            return "yellow"
        }
    }
}

protocol ReaderOutputProtocol {
    func ready()
    func didTapClearHighlight()
    func didTapHighlight(color: String)
    func didTapCopy()
    func didTapShare()
    func didLoadContent(content: String)
    func didClickVerse(verse: String)
    func didReceiveHighlights(highlights: String)
    func didReceiveComment(comment: String, elementId: String)
    func didReceiveCopy(text: String)
    func didReceiveShare(text: String)
}

open class Reader: UIWebView {
    var readerViewDelegate: ReaderOutputProtocol?
    var menuVisible = false
    var contextMenuEnabled = false
    
    func createContextMenu(){
        let highlightGreen = UIMenuItem(title: "*", image: R.image.iconHighlightGreen()) { [weak self] _ in
            self?.readerViewDelegate?.didTapHighlight(color: ReaderStyle.Highlight.Green)
        }
        
        let highlightBlue = UIMenuItem(title: "*", image: R.image.iconHighlightBlue()) { [weak self] _ in
            self?.readerViewDelegate?.didTapHighlight(color: ReaderStyle.Highlight.Blue)
        }
        
        let highlightYellow = UIMenuItem(title: "*", image: R.image.iconHighlightYellow()) { [weak self] _ in
            self?.readerViewDelegate?.didTapHighlight(color: ReaderStyle.Highlight.Yellow)
        }
        
        let highlightOrange = UIMenuItem(title: "*", image: R.image.iconHighlightOrange()) { [weak self] _ in
            self?.readerViewDelegate?.didTapHighlight(color: ReaderStyle.Highlight.Orange)
        }
        
        let clearHighlight = UIMenuItem(title: "*", image: R.image.iconHighlightClear()) { [weak self] _ in
            self?.readerViewDelegate?.didTapClearHighlight()
        }
        
        let copy = UIMenuItem(title: "Copy".localized()) { [weak self] _ in
            self?.readerViewDelegate?.didTapCopy()
        }
        
        let share = UIMenuItem(title: "Share".localized()) { [weak self] _ in
            self?.readerViewDelegate?.didTapShare()
        }
        UIMenuController.shared.menuItems = [highlightGreen, highlightBlue, highlightYellow, highlightOrange, clearHighlight, copy, share]
    }
    
    func setupContextMenu(){
        createContextMenu()
        showContextMenu()
    }
    
    func showContextMenu(){
        let rect = CGRectFromString("{{-1000, -1000}, {-1000, -10000}}")
        UIMenuController.shared.setTargetRect(rect, in: self)
        UIMenuController.shared.setMenuVisible(true, animated: false)
    }
    
    func highlight(color: String){
        self.stringByEvaluatingJavaScript(from: "ssReader.highlightSelection('"+color+"');")
        self.isUserInteractionEnabled = false
        self.isUserInteractionEnabled = true
    }
    
    func copyText(){
        self.stringByEvaluatingJavaScript(from: "ssReader.copy()")
        self.isUserInteractionEnabled = false
        self.isUserInteractionEnabled = true
    }
    
    func shareText(){
        self.stringByEvaluatingJavaScript(from: "ssReader.share()")
        self.isUserInteractionEnabled = false
        self.isUserInteractionEnabled = true
    }
    
    func clearHighlight(){
        self.stringByEvaluatingJavaScript(from: "ssReader.unHighlightSelection()")
        self.isUserInteractionEnabled = false
        self.isUserInteractionEnabled = true
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if !contextMenuEnabled { return super.canPerformAction(action, withSender: sender) }
        return false
    }
    
    func loadContent(content: String){
        var indexPath = Bundle.main.path(forResource: "index", ofType: "html")
        
        let exists = FileManager.default.fileExists(atPath: Constants.Path.readerBundle.path)
        
        if exists {
            indexPath = Constants.Path.readerBundle.path
        }
        
        var index = try? String(contentsOfFile: indexPath!, encoding: String.Encoding.utf8)
        index = index?.replacingOccurrences(of: "{{content}}", with: content)
        
        if !exists {
            index = index?.replacingOccurrences(of: "css/", with: "")
            index = index?.replacingOccurrences(of: "js/", with: "")
        }
        
        let theme = currentTheme()
        let typeface = currentTypeface()
        let size = currentSize()
        
        if !theme.isEmpty {
            index = index?.replacingOccurrences(of: "ss-wrapper-light", with: "ss-wrapper-"+theme)
        }
        
        if !typeface.isEmpty {
            index = index?.replacingOccurrences(of: "ss-wrapper-andada", with: "ss-wrapper-"+typeface)
        }
        
        if !size.isEmpty {
            index = index?.replacingOccurrences(of: "ss-wrapper-medium", with: "ss-wrapper-"+size)
        }
        if exists {
            self.loadHTMLString(index!, baseURL: Constants.Path.readerBundleDir)
        } else {
            self.loadHTMLString(index!, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
        }
        
        self.readerViewDelegate?.didLoadContent(content: index!)
    }
    
    func shouldStartLoad(request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let url = request.url else { return false }
        
        if let _ = url.valueForParameter(key: "ready") {
            self.readerViewDelegate?.ready()
            return false
        }
        
        if let text = url.valueForParameter(key: "copy") {
            self.readerViewDelegate?.didReceiveCopy(text: text)
            return false
        }
        
        if let text = url.valueForParameter(key: "share") {
            self.readerViewDelegate?.didReceiveShare(text: text)
            return false
        }
        
        if let verse = url.valueForParameter(key: "verse"), let decoded = verse.base64Decode() {
            self.readerViewDelegate?.didClickVerse(verse: decoded)
            return false
        }
        
        if let highlights = url.valueForParameter(key: "highlights") {
            self.readerViewDelegate?.didReceiveHighlights(highlights: highlights)
            return false
        }
        
        if let comment = url.valueForParameter(key: "comment"), let decodedComment = comment.base64Decode() {
            if let elementId = url.valueForParameter(key: "elementId") {
                self.readerViewDelegate?.didReceiveComment(comment: decodedComment, elementId: elementId)
                return false
            }

            return false
        }
        
        if let scheme = url.scheme, (scheme == "http" || scheme == "https"), navigationType == .linkClicked {
            // TODO: open external SafariVC or external browser
        }
        
        return true
    }
    
    func setTheme(_ theme: String){
        self.stringByEvaluatingJavaScript(from: "ssReader.setTheme('"+theme+"')")
    }
    
    func setTypeface(_ typeface: String){
        self.stringByEvaluatingJavaScript(from: "ssReader.setFont('"+typeface+"')")
    }
    
    func setSize(_ size: String){
        self.stringByEvaluatingJavaScript(from: "ssReader.setSize('"+size+"')")
    }
    
    func setHighlights(_ highlights: String){
        self.stringByEvaluatingJavaScript(from: "ssReader.setHighlights('"+highlights+"')")
    }
    
    func setComment(_ comment: Comment){
        self.stringByEvaluatingJavaScript(from: "ssReader.setComment('"+comment.comment.base64Encode()!+"', '"+comment.elementId+"')")
    }
}
