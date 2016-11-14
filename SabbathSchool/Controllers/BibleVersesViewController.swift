//
//  BibleVersesViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 14/11/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class BibleVersesViewController: ASViewController<ASDisplayNode> {
    let versesNode = VersesNode()
    var bibleVerses: [BibleVerses]!
    let verse: String!
    fileprivate var selectedVerse: String!
    
    init(bibleVerses: [BibleVerses], verse: String) {
        self.bibleVerses = bibleVerses
        self.verse = verse
        
        super.init(node: versesNode)
        
        title = verse
        
        if let bibleVersion = bibleVerses.first, let openVerse = bibleVersion.verses[verse] {
            selectedVerse = openVerse
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let indexPath = Bundle.main.path(forResource: "index", ofType: "html")
        var index = try? String(contentsOfFile: indexPath!, encoding: String.Encoding.utf8)
        index = index?.replacingOccurrences(of: "{{content}}", with: selectedVerse)
        index = index?.replacingOccurrences(of: "css/", with: "") // Fix the css path
        index = index?.replacingOccurrences(of: "js/", with: "") // Fix the js path
        
        versesNode.webView.loadHTMLString(index!, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
    }
}
