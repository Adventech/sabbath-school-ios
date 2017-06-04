//
//  Reader.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-01.
//  Copyright © 2017 Adventech. All rights reserved.
//

import UIKit

enum ReaderTheme: String {
    case Light = "light"
    case Dark = "dark"
    case Sepia = "sepia"
}

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
}

@objc protocol ReaderOutputProtocol {
    @objc optional func didLoadContent(content: String)
    @objc optional func didChangeTheme(theme: String)
    
    // TODO: Remove
    @objc optional func didLoadReadContent(content: String)
}

class Reader {
    var delegate: ReaderOutputProtocol?
    
    init(){}
    
    func loadContent(content: String){
        let indexPath = Bundle.main.path(forResource: "index", ofType: "html")
        var index = try? String(contentsOfFile: indexPath!, encoding: String.Encoding.utf8)
        index = index?.replacingOccurrences(of: "{{content}}", with: content)
        index = index?.replacingOccurrences(of: "css/", with: "") // Fix the css path
        index = index?.replacingOccurrences(of: "js/", with: "") // Fix the js path
        delegate?.didLoadContent!(content: index!)
    }
    
    // TODO: Remove
    func loadReadContent(read: Read){
        let indexPath = Bundle.main.path(forResource: "index", ofType: "html")
        var index = try? String(contentsOfFile: indexPath!, encoding: String.Encoding.utf8)
        index = index?.replacingOccurrences(of: "{{content}}", with: read.content)
        index = index?.replacingOccurrences(of: "css/", with: "") // Fix the css path
        index = index?.replacingOccurrences(of: "js/", with: "") // Fix the js path
        delegate?.didLoadReadContent!(content: index!)
    }
    
    func setThemeLight() {
        delegate?.didChangeTheme!(theme: ReaderStyle.Theme.Light)
    }
}
