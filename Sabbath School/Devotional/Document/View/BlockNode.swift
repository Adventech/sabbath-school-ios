/*
 * Copyright (c) 2022 Adventech <info@adventech.io>
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

import AsyncDisplayKit

protocol BlockActionsDelegate {
    func didClickBible(bibleVerses: [BibleVerses], verse: String)
    func didClickURL(url: URL)
    func didClickReference(scope: Block.ReferenceScope, index: String)
}

class BlockNode: ASControlNode {
    private let block: BlockWrapperNode
    private var userSelected: Bool = false
    init(block: BlockWrapperNode){
        self.block = block
        super.init()
        addSubnode(block)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.backgroundColor = .clear
        block.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(constrainedSize.max.width), height: ASDimensionMake(.auto, 0))
        return ASInsetLayoutSpec(insets: block.margins, child: block)
    }
    
    override func didLoad() {
        super.didLoad()
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        self.view.addGestureRecognizer(
            lpgr
        )
        self.addTarget(self, action: #selector(didPlaylistToggle(_:)), forControlEvents: .touchDownRepeat)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            changeBlockState()
        }
    }
    
    @objc func didPlaylistToggle(_ sender: ASControlNode) {
        changeBlockState()
    }
    
    private func changeBlockState() {
        self.userSelected = !self.userSelected
        block.didToggleHighlightBlock(highlight: self.userSelected)
    }
}
