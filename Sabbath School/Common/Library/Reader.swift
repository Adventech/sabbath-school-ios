//
//  ReaderView.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-04.
//  Copyright © 2017 Adventech. All rights reserved.
//

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
    func didTapHighlight(color: String)
    func didLoadContent(content: String)
    func didClickVerse(verse: String)
    func didReceiveHighlights(highlights: String)
    func didReceiveComment(comment: String, elementId: String)
}

open class Reader: UIWebView {
    var readerViewDelegate: ReaderOutputProtocol?
    var menuVisible = false
    var contextMenuEnabled = false
    
    func setupContextMenu(){
        if !contextMenuEnabled { return }
        
        let highlightGreen = UIMenuItem(title: "*", image: R.image.iconHighlightGreen()) { _ in
            self.readerViewDelegate?.didTapHighlight(color: ReaderStyle.Highlight.Green)
        }
        
        let highlightBlue = UIMenuItem(title: "*", image: R.image.iconHighlightBlue()) { _ in
            self.readerViewDelegate?.didTapHighlight(color: ReaderStyle.Highlight.Blue)
        }
        
        let highlightYellow = UIMenuItem(title: "*", image: R.image.iconHighlightYellow()) { _ in
            self.readerViewDelegate?.didTapHighlight(color: ReaderStyle.Highlight.Yellow)
        }
        
        let highlightOrange = UIMenuItem(title: "*", image: R.image.iconHighlightOrange()) { _ in
            self.readerViewDelegate?.didTapHighlight(color: ReaderStyle.Highlight.Orange)
        }
        
        let copy = UIMenuItem(title: "Copy") { [weak self] _ in
//            self?.readerViewDelegate?.didTapHighlightGreen()
        }
        
        let share = UIMenuItem(title: "Share") { [weak self] _ in
//            self?.readerViewDelegate?.didTapHighlightGreen()
        }
        
        UIMenuController.shared.menuItems = [highlightGreen, highlightBlue, highlightYellow, highlightOrange, copy, share]
        showContextMenu()
    }
    
    func showContextMenu(){
        if menuVisible { return }
        let rect = CGRectFromString("{{-1000, -1000}, {-1000, -1000}}")
        UIMenuController.shared.setTargetRect(rect, in: self)
        UIMenuController.shared.setMenuVisible(true, animated: false)
        menuVisible = true
    }
    
    func highlight(color: String){
        self.stringByEvaluatingJavaScript(from: "ssReader.highlightSelection('"+color+"');")
        self.isUserInteractionEnabled = false
        self.isUserInteractionEnabled = true
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if !contextMenuEnabled { return super.canPerformAction(action, withSender: sender) }
        return false
    }
    
    func loadContent(content: String){
        let indexPath = Bundle.main.path(forResource: "index", ofType: "html")
        var index = try? String(contentsOfFile: indexPath!, encoding: String.Encoding.utf8)
        index = index?.replacingOccurrences(of: "{{content}}", with: content)
        index = index?.replacingOccurrences(of: "css/", with: "")
        index = index?.replacingOccurrences(of: "js/", with: "")
        
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
        
        self.loadHTMLString(index!, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
        self.readerViewDelegate?.didLoadContent(content: index!)
    }
    
    func shouldStartLoad(request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let url = request.url else { return false }
        
        if let _ = url.valueForParameter(key: "ready") {
            self.readerViewDelegate?.ready()
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
        self.stringByEvaluatingJavaScript(from: "ssReader.setTypeface('"+typeface+"')")
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
