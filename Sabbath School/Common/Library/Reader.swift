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
import WebKit

struct ReaderStyle {
    enum Theme: String {
        case light
        case sepia
        case dark

        static var items: [Theme] {
            return [
                .light,
                .sepia,
                .dark
            ]
        }

        var backgroundColor: UIColor {
            switch self {
            case .light: return AppStyle.Reader.Color.white
            case .sepia: return AppStyle.Reader.Color.sepia
            case .dark: return AppStyle.Reader.Color.dark
            }
        }

        var navBarColor: UIColor {
            switch self {
            case .light: return AppStyle.Reader.Color.white
            case .sepia: return AppStyle.Reader.Color.sepia
            case .dark: return AppStyle.Reader.Color.dark
            }
        }

        var navBarTextColor: UIColor {
            switch self {
            case .light: return .black
            case .sepia: return .black
            case .dark: return .white
            }
        }
    }

    enum Typeface: String {
        case andada
        case lato
        case ptSerif = "pt-serif"
        case ptSans = "pt-sans"

        static var items: [Typeface] {
            return [
                .andada,
                .lato,
                .ptSerif,
                .ptSans
            ]
        }
    }

    enum Size: String, CaseIterable {
        case tiny
        case small
        case medium
        case large
        case huge

        static var items: [Size] {
            return [
                .tiny,
                .small,
                .medium,
                .large,
                .huge
            ]
        }
    }

    enum Highlight: String {
        case green
        case blue
        case orange
        case yellow

        static var items: [Highlight] {
            return [
                .green,
                .blue,
                .orange,
                .yellow
            ]
        }
    }
}

extension CaseIterable where Self: Equatable {
    var index: Self.AllCases.Index? {
        return Self.allCases.firstIndex { self == $0 }
    }
}

protocol ReaderOutputProtocol: AnyObject {
    func ready()
    func didTapClearHighlight()
    func didTapHighlight(color: String)
    func didLoadContent(content: String)
    func didClickVerse(verse: String)
    func didReceiveHighlights(highlights: String)
    func didReceiveComment(comment: String, elementId: String)
    func didReceiveCopy(text: String)
    func didReceiveShare(text: String)
    func didReceiveLookup(text: String)
    func didTapExternalUrl(url: URL)
}

open class Reader: WKWebView {
    weak var readerViewDelegate: ReaderOutputProtocol?
    var menuVisible = false
    var contextMenuEnabled = false

    func createContextMenu() {
        let highlightGreen = UIMenuItem(title: "Green", image: R.image.iconHighlightGreen()) { [weak self] _ in
            self?.readerViewDelegate?.didTapHighlight(color: ReaderStyle.Highlight.green.rawValue)
        }

        let highlightBlue = UIMenuItem(title: "Blue", image: R.image.iconHighlightBlue()) { [weak self] _ in
            self?.readerViewDelegate?.didTapHighlight(color: ReaderStyle.Highlight.blue.rawValue)
        }

        let highlightYellow = UIMenuItem(title: "Yellow", image: R.image.iconHighlightYellow()) { [weak self] _ in
            self?.readerViewDelegate?.didTapHighlight(color: ReaderStyle.Highlight.yellow.rawValue)
        }

        let highlightOrange = UIMenuItem(title: "Orange", image: R.image.iconHighlightOrange()) { [weak self] _ in
            self?.readerViewDelegate?.didTapHighlight(color: ReaderStyle.Highlight.orange.rawValue)
        }

        let clearHighlight = UIMenuItem(title: "Clear", image: R.image.iconHighlightClear()) { [weak self] _ in
            self?.readerViewDelegate?.didTapClearHighlight()
        }

        UIMenuController.shared.menuItems = [highlightGreen, highlightBlue, highlightYellow, highlightOrange, clearHighlight]
    }

    func setupContextMenu() {
        createContextMenu()
        showContextMenu()
    }

    func showContextMenu() {
        let rect = NSCoder.cgRect(for: "{{-1000, -1000}, {-1000, -10000}}")
        UIMenuController.shared.setTargetRect(rect, in: self)
        UIMenuController.shared.setMenuVisible(true, animated: false)
    }

    func highlight(color: String) {
        evaluateJavaScript("ssReader.highlightSelection('"+color+"');")
        self.isUserInteractionEnabled = false
        self.isUserInteractionEnabled = true
    }
    
    func clearHighlight() {
        evaluateJavaScript("ssReader.unHighlightSelection()")
        self.isUserInteractionEnabled = false
        self.isUserInteractionEnabled = true
    }

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if !contextMenuEnabled { return super.canPerformAction(action, withSender: sender) }
        return false
    }

    func loadContent(content: String) {
        var indexPath = Bundle.main.path(forResource: "index", ofType: "html")

        let exists = FileManager.default.fileExists(atPath: Constants.Path.readerBundle.path)

        if exists {
            indexPath = Constants.Path.readerBundle.path
        }

        var index = try? String(contentsOfFile: indexPath!, encoding: .utf8)
        index = index?.replacingOccurrences(of: "{{content}}", with: content)

        if !exists {
            index = index?.replacingOccurrences(of: "css/", with: "")
            index = index?.replacingOccurrences(of: "js/", with: "")
        }

        let theme = Preferences.currentTheme()
        let typeface = Preferences.currentTypeface()
        let size = Preferences.currentSize()

        index = index?.replacingOccurrences(of: "ss-wrapper-light", with: "ss-wrapper-"+theme.rawValue)
        index = index?.replacingOccurrences(of: "ss-wrapper-andada", with: "ss-wrapper-"+typeface.rawValue)
        index = index?.replacingOccurrences(of: "ss-wrapper-medium", with: "ss-wrapper-"+size.rawValue)

        guard let index = index else { return }
        
        if exists {
            // looks like WKWebView doesn't allow access local resources from the Documents folder using loadHTMLString, but when I use loadFileURL allowingReadAccessTo allow to load js and css files from local filesystem, remove this when possible.
            loadFileURL(Constants.Path.readerBundle, allowingReadAccessTo: Constants.Path.readerBundleDir)
            loadHTMLString(index, baseURL: Constants.Path.readerBundleDir)
        } else {
            loadHTMLString(index, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
        }

        self.readerViewDelegate?.didLoadContent(content: index)
    }

    func setTheme(_ theme: ReaderStyle.Theme) {
        evaluateJavaScript("ssReader.setTheme('"+theme.rawValue+"')")
    }

    func setTypeface(_ typeface: ReaderStyle.Typeface) {
        evaluateJavaScript("ssReader.setFont('"+typeface.rawValue+"')")
    }

    func setSize(_ size: ReaderStyle.Size) {
        evaluateJavaScript("ssReader.setSize('"+size.rawValue+"')")
    }

    func setHighlights(_ highlights: String) {
        evaluateJavaScript("ssReader.setHighlights('"+highlights+"')")
    }

    func setComment(_ comment: Comment) {
        evaluateJavaScript("ssReader.setComment('"+comment.comment.base64Encode()!+"', '"+comment.elementId+"')")
    }
}
