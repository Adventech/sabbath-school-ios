//
//  Reader.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 28/10/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit

/**
 *  Themeable protocol that defines get set from SDK and get the CSS class.
 */
protocol ReaderThemeable {
    associatedtype Themeable
    
    static var current: Themeable { get set }
    func cssClass() -> String
}

// MARK: Reader Theme

enum ReaderTheme: String {
    case light = "light"
    case dark = "dark"
    case sepia = "sepia"
    
    init() {
        self = .light
    }
    
    init?(index: Int) {
        let themes = [ReaderTheme.light.rawValue, ReaderTheme.dark.rawValue, ReaderTheme.sepia.rawValue]
        if index < themes.count {
            self = ReaderTheme(rawValue: themes[index])!
        } else {
            return nil
        }
    }
}

extension ReaderTheme: ReaderThemeable {
    static var current: ReaderTheme {
        get {
            return ReaderTheme()
//            guard let readerSettings = Manager.shared.readerSettings.data else { return ReaderTheme() }
//            return ReaderTheme(rawValue: readerSettings.theme)!
        }
        set (value) {
//            guard let current = Manager.shared.readerSettings.data else { return }
//            let readerSettings = UserReaderSettings(fontType: current.fontType, fontSize: current.fontSize, theme: value.rawValue)
//            Manager.shared.readerSettings.setData(readerSettings)
        }
    }
    
    /**
     Returns CSS class for ReaderTheme.
     */
    func cssClass() -> String {
        return "reader--\(self.rawValue)"
    }
    
    /**
     Returns UIColor for ReaderTheme.
     */
    func colorForTheme() -> UIColor {
        switch self {
        case .light:
            return UIColor.readerWhite
        case .dark:
            return UIColor.readerDark
        case .sepia:
            return UIColor.readerSepia
        }
    }
}

// MARK: Font Style

enum ReaderFontStyle: String {
    case serif = "serif"
    case sans = "sans"
    
    init() {
        self = .serif
    }
    
    init?(index: Int) {
        let themes = [ReaderFontStyle.serif.rawValue, ReaderFontStyle.sans.rawValue]
        if index < themes.count {
            self = ReaderFontStyle(rawValue: themes[index])!
        } else {
            return nil
        }
    }
}

extension ReaderFontStyle: ReaderThemeable {
    static var current: ReaderFontStyle {
        get {
            return ReaderFontStyle()
//            guard let readerSettings = Manager.shared.readerSettings.data else { return ReaderFontStyle() }
//            return ReaderFontStyle(rawValue: readerSettings.fontType)!
        }
        set (value) {
//            guard let current = Manager.shared.readerSettings.data else { return }
//            let readerSettings = UserReaderSettings(fontType: value.rawValue, fontSize: current.fontSize, theme: current.theme)
//            Manager.shared.readerSettings.setData(readerSettings)
        }
    }
    
    /**
     Returns CSS class for ReaderFontStyle.
     */
    func cssClass() -> String {
        return "reader-typeface--\(self.rawValue)"
    }
}

// MARK: Font Size

enum ReaderFontSize: Int {
    case one = 1
    case two
    case three
    case four
    case five
    
    init() {
        self = .one
    }
    
    init?(index: Int) {
        if index < ReaderFontSize.five.rawValue {
            self = ReaderFontSize(rawValue: index+1)!
        } else {
            return nil
        }
    }
}

extension ReaderFontSize: ReaderThemeable {
    static var current: ReaderFontSize {
        get {
            return ReaderFontSize()
//            guard let readerSettings = Manager.shared.readerSettings.data else { return ReaderFontSize() }
//            return ReaderFontSize(rawValue: readerSettings.fontSize)!
        }
        set (value) {
//            guard let current = Manager.shared.readerSettings.data else { return }
//            let readerSettings = UserReaderSettings(fontType: current.fontType, fontSize: value.rawValue, theme: current.theme)
//            Manager.shared.readerSettings.setData(readerSettings)
        }
    }
    
    /**
     Returns CSS class for ReaderFontSize.
     */
    func cssClass() -> String {
        return "reader-font-size--\(self.rawValue)"
    }
}
