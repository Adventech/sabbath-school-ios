/*
 * Copyright (c) 2021 Adventech <info@adventech.io>
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
import Down
import UIKit

struct SSPMColorCollection: ColorCollection {

    // MARK: - Properties
    public var heading1: DownColor
    public var heading2: DownColor
    public var heading3: DownColor
    public var heading4: DownColor
    public var heading5: DownColor
    public var heading6: DownColor
    public var body: DownColor
    public var code: DownColor
    public var link: DownColor
    public var quote: DownColor
    public var quoteStripe: DownColor
    public var thematicBreak: DownColor
    public var listItemPrefix: DownColor
    public var codeBlockBackground: DownColor

    // MARK: - Life cycle
    public init(
        heading1: DownColor = .black,
        heading2: DownColor = .black,
        heading3: DownColor = .black,
        heading4: DownColor = .black,
        heading5: DownColor = .black,
        heading6: DownColor = .black,
        body: DownColor = AppStyle.Quarterly.Color.introduction,
        code: DownColor = AppStyle.Quarterly.Color.introduction,
        link: DownColor = AppStyle.Quarterly.Color.introduction,
        quote: DownColor = .darkGray,
        quoteStripe: DownColor = .darkGray,
        thematicBreak: DownColor = .init(white: 0.9, alpha: 1),
        listItemPrefix: DownColor = .lightGray,
        codeBlockBackground: DownColor = .init(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
    ) {
        self.heading1 = heading1
        self.heading2 = heading2
        self.heading3 = heading3
        self.heading4 = heading4
        self.heading5 = heading5
        self.heading6 = heading6
        self.body = body
        self.code = code
        self.link = link
        self.quote = quote
        self.quoteStripe = quoteStripe
        self.thematicBreak = thematicBreak
        self.listItemPrefix = listItemPrefix
        self.codeBlockBackground = codeBlockBackground
    }

}

struct SSPMParagraphStyleCollection: ParagraphStyleCollection {
    // MARK: - Properties
    public var heading1: NSParagraphStyle
    public var heading2: NSParagraphStyle
    public var heading3: NSParagraphStyle
    public var heading4: NSParagraphStyle
    public var heading5: NSParagraphStyle
    public var heading6: NSParagraphStyle
    public var body: NSParagraphStyle
    public var code: NSParagraphStyle

    // MARK: - Life cycle
    public init() {
        let headingStyle = NSMutableParagraphStyle()
        headingStyle.paragraphSpacing = 8

        let bodyStyle = NSMutableParagraphStyle()
        bodyStyle.paragraphSpacingBefore = 0
        bodyStyle.paragraphSpacing = 0
        bodyStyle.lineSpacing = 3

        let codeStyle = NSMutableParagraphStyle()
        codeStyle.paragraphSpacingBefore = 8
        codeStyle.paragraphSpacing = 8

        heading1 = headingStyle
        heading2 = headingStyle
        heading3 = headingStyle
        heading4 = headingStyle
        heading5 = headingStyle
        heading6 = headingStyle
        body = bodyStyle
        code = codeStyle
    }

}

class SSPMFontCollection: FontCollection {
    public var heading1: DownFont
    public var heading2: DownFont
    public var heading3: DownFont
    public var heading4: DownFont
    public var heading5: DownFont
    public var heading6: DownFont
    public var body: DownFont
    public var code: DownFont
    public var listItemPrefix: DownFont

    public init(
        heading1: DownFont = R.font.latoRegular(size: 28)!,
        heading2: DownFont = R.font.latoRegular(size: 24)!,
        heading3: DownFont = R.font.latoRegular(size: 20)!,
        heading4: DownFont = R.font.latoRegular(size: 20)!,
        heading5: DownFont = R.font.latoRegular(size: 20)!,
        heading6: DownFont = R.font.latoRegular(size: 20)!,
        body: DownFont = R.font.latoMedium(size: 18)!,
        code: DownFont = DownFont(name: "menlo", size: 17) ?? .systemFont(ofSize: 17),
        listItemPrefix: DownFont = DownFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
    ) {
        self.heading1 = heading1
        self.heading2 = heading2
        self.heading3 = heading3
        self.heading4 = heading4
        self.heading5 = heading5
        self.heading6 = heading6
        self.body = body
        self.code = code
        self.listItemPrefix = listItemPrefix
    }
}

class SSPMStyler: DownStyler {
    override func style(link str: NSMutableAttributedString, title: String?, url: String?) {
        guard let url = url else { return }
        
        // TODO: In future style URLs depending on their type potentially
        
        str.addAttributes(
            [
                .link: url,
                .font: R.font.latoBold(size: 18)!,
                .foregroundColor: url.contains("Luke") ? UIColor.baseRed : UIColor.baseBlue,
                .underlineColor: UIColor.clear
            ],
            range: NSRange(location: 0, length: str.length)
        )
    }
}

class BlockNode: ASControlNode {
    private let block: ASDisplayNode
    private var userSelected: Bool = false
    init(block: ASDisplayNode){
        self.block = block
        super.init()
        self.cornerRadius = 6.0
        addSubnode(block)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.backgroundColor = .clear
        block.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMake(constrainedSize.max.width), height: ASDimensionMake(.auto, 0))
        if self.userSelected { self.backgroundColor = UIColor(hex: "#B3DFFD") }
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), child: block)
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
            a()
        }
    }
    
    @objc func didPlaylistToggle(_ sender: ASControlNode) {
        a()
    }
    
    private func a() {
        print("SSDEBUG, touch")
        self.userSelected = !self.userSelected
        self.setNeedsLayout()
    }
}

class TextNode: ASDisplayNode, ASTextNodeDelegate {
    private let text = ASTextNode()
    private var selected: Bool = false
    
    public init(text: String, selectable: Bool = false) {
        super.init()
        let down = Down(markdownString: text)
        
        let downStylerConfiguration = DownStylerConfiguration(
            fonts: SSPMFontCollection(),
            colors: SSPMColorCollection(),
            paragraphStyles: SSPMParagraphStyleCollection()
        )
        
        let styler = SSPMStyler(configuration: downStylerConfiguration)
       
        self.text.delegate = self
        self.text.attributedText = try! down.toAttributedString(styler: styler)
        self.text.isUserInteractionEnabled = true
        self.text.highlightStyle = .dark
        self.text.passthroughNonlinkTouches = true
        
        addSubnode(self.text)
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        if selected {
            self.backgroundColor = .baseBlue
        }
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: self.text)
    }
    
    public func textNode(_ textNode: ASTextNode,
                         tappedLinkAttribute attribute: String,
                         value: Any, at point: CGPoint,
                         textRange: NSRange) {
        print("SSDEBUG", "YOOOOO", value)
        if let url = value as? URL {
            print("SSDEBUG", url)
        }
    }
}

class ParagraphNode: ASDisplayNode {
    private let textNode: ASDisplayNode
    public init(block: Block.Paragraph) {
        textNode = TextNode(text: block.markdown, selectable: false)
        super.init()
        addSubnode(textNode)
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: textNode)
    }
}

class HeadingNode: ASDisplayNode {
    private let text = ASTextNode()
    
    public init(block: Block.Heading) {
        super.init()
        automaticallyManagesSubnodes = true
        text.attributedText = AppStyle.Markdown.Text.heading(string: block.markdown, depth: block.depth)
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: AppStyle.Markdown.Size.headingSpacing().top, left: 0, bottom: AppStyle.Markdown.Size.headingSpacing().bottom, right: 0), child: text)
    }
}

class HorizonalLineNode: ASDisplayNode {
    private let line = ASDisplayNode()
    public init(block: Block.Hr) {
        super.init()
        self.line.backgroundColor = .baseBlue
        addSubnode(self.line)
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.line.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 1.0)
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: self.line)
    }
}

class ListItemNode: ASDisplayNode {
    private let textNode: ASDisplayNode
    public init(text: String) {
        textNode = TextNode(text: text, selectable: false)
        super.init()
        addSubnode(textNode)
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: textNode)
    }
}

class ListNode: ASDisplayNode {
    private let depth: Int
    private var itemNodes: [ASLayoutElement] = []
    
    public init(block: Block.List, depth: Int = 1) {
        self.depth = depth
        super.init()
        
        if let items = block.items {
            for (itemIndex, item) in items.enumerated() {
                switch item {
                case .list(let subList):
                    let listItemNode = ListNode(block: subList, depth: depth + 1)
                    addSubnode(listItemNode)
                    itemNodes.append(listItemNode)
                    
                case .listItem(let listItem):
                    var bullet: String = ""
                    
                    switch self.depth {
                    case 1:
                        bullet = "●"
                    case 2:
                        bullet = "○"
                    default:
                        bullet = "◆"
                    }
                    
                    if let ordered = block.ordered,
                       let start = block.start,
                       ordered {
                       bullet = "\(start + itemIndex)."
                    }
                    
                    let bulletNode = ASTextNode()
                    bulletNode.attributedText = AppStyle.Markdown.Text.listBullet(string: bullet, ordered: block.ordered ?? false)
                    
                    let listItemNode = ListItemNode(text: listItem.markdown)
                    
                    let vSpec = ASStackLayoutSpec(
                        direction: .horizontal,
                        spacing: 10,
                        justifyContent: .start,
                        alignItems: .start,
                        children: [bulletNode, listItemNode]
                    )
                    
                    addSubnode(bulletNode)
                    addSubnode(listItemNode)
                    
                    listItemNode.style.flexShrink = 1.0
                    
                    itemNodes.append(vSpec)
                default: break
                }
            }
        }
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .start,
            children: itemNodes
        )
        
        let bottom: CGFloat = (self.depth > 1) ? 0 : 20.0
        let left: CGFloat = (CGFloat(self.depth)-1) * 5.0
        
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: left, bottom: bottom, right: 0), child: vSpec)
    }
}

class ReferenceNode: ASDisplayNode {
    private let title = ASTextNode()
    private let subtitle = ASTextNode()
    private let actionIcon = ASImageNode()
    
    private let block: Block.Reference
    
    public init(block: Block.Reference) {
        self.block = block
        super.init()
        self.cornerRadius = 4
        self.backgroundColor = .baseGray1
        title.attributedText = AppStyle.Markdown.Text.Reference.title(string: block.title)
        title.maximumNumberOfLines = 1
        title.truncationMode = .byTruncatingTail
        
        if block.subtitle != nil {
            subtitle.attributedText = AppStyle.Markdown.Text.Reference.subtitle(string: block.subtitle!)
            subtitle.maximumNumberOfLines = 1
            subtitle.truncationMode = .byTruncatingTail
        }
        
        actionIcon.image = R.image.iconMore()?.fillAlpha(fillColor: AppStyle.Markdown.Color.Reference.actionIcon)
        
        addSubnode(title)
        addSubnode(subtitle)
        addSubnode(actionIcon)
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        title.style.maxWidth = ASDimensionMake(constrainedSize.max.width)
        
        var children: [ASLayoutElement] = [title]
        
        if self.block.subtitle != nil {
            children.insert(self.subtitle, at: 0)
        }
        
        let titles = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 5,
            justifyContent: .start,
            alignItems: .start,
            children: children
        )
        
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [titles, actionIcon]
        )
        
        titles.style.maxWidth = ASDimensionMakeWithPoints(constrainedSize.max.width-40)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), child: hSpec)
    }
}

class QuestionNode: ASDisplayNode {
    private let question = ASTextNode()
    private let answer = ASEditableTextNode()
    
    public init(block: Block.Question) {
        super.init()
        let down = Down(markdownString: block.markdown)
        
        let downStylerConfiguration = DownStylerConfiguration(
            fonts: SSPMFontCollection(body: R.font.latoBlack(size: 20)!),
            colors: SSPMColorCollection(),
            paragraphStyles: SSPMParagraphStyleCollection()
        )
        
        let styler = SSPMStyler(configuration: downStylerConfiguration)
        self.question.attributedText = try! down.toAttributedString(styler: styler)
        
        self.answer.backgroundColor = .yellow
        self.answer.borderColor = UIColor(hex: "#ECE4C3").cgColor
        self.answer.borderWidth = 1
        self.answer.cornerRadius = 3
        self.answer.backgroundColor = UIColor(hex: "#FFF9DF")
        self.answer.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.answer.typingAttributes = AppStyle.Markdown.Text.answer()
        
        addSubnode(question)
        addSubnode(answer)
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        answer.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 200)
        
        let hSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 10,
            justifyContent: .start,
            alignItems: .start,
            children: [question, answer]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: hSpec)
    }
}

class BlockquoteNode: ASDisplayNode {
    private var nestedBlocks: [ASLayoutElement] = []
    private let line = ASDisplayNode()
    private let caption = ASTextNode()
    private let block: Block.Blockquote
    
    public init(block: Block.Blockquote) {
        self.block = block
        super.init()
        
        self.line.backgroundColor = .baseGray1
        self.line.cornerRadius = 3.0
        self.nestedBlocks = processBlocks(blocks: block.items)
        
        if let caption = block.caption, !caption.isEmpty {
            if let _ = block.memoryVerse {
                self.caption.attributedText = AppStyle.Markdown.Text.Blockquote.memoryText(string: caption)
            }
            
            if let _ = block.citation {
                self.caption.attributedText = AppStyle.Markdown.Text.Blockquote.citation(string: caption)
            }
        }
        automaticallyManagesSubnodes = true
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.line.style.minWidth = ASDimensionMake(7)
        self.line.style.alignSelf = .stretch
        
        
        if let caption = block.caption, !caption.isEmpty {
            let captionBlock = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0), child: self.caption)
            if let _ = block.memoryVerse {
                nestedBlocks.insert(captionBlock, at: 0)
            }
            
            if let _ = block.citation {
                nestedBlocks.append(captionBlock)
            }
        }
        
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 10,
            justifyContent: .start,
            alignItems: .start,
            children: nestedBlocks
        )
        
        vSpec.style.maxWidth = ASDimensionMakeWithPoints(constrainedSize.max.width-15)
        
        
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 5,
            justifyContent: .start,
            alignItems: .center,
            children: [line, vSpec]
        )
        
        hSpec.style.flexGrow = 1.0
        hSpec.style.maxWidth = ASDimensionMakeWithPoints(constrainedSize.max.width)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: hSpec)
    }
}

class CollapseNode: ASDisplayNode {
    private var nestedBlocks: [ASLayoutElement] = []
    private let header = ASDisplayNode()
    private let content = ASDisplayNode()
    private let caption = ASTextNode()
    private let actionIcon = ASImageNode()
    
    private var collapsed = true
    
    public init(block: Block.Collapse) {
        super.init()
        self.nestedBlocks = processBlocks(blocks: block.items)
        self.caption.maximumNumberOfLines = 2
        self.caption.truncationMode = .byTruncatingTail
        self.caption.attributedText = AppStyle.Markdown.Text.collapseHeader(string: block.caption)
        
        self.header.backgroundColor = .baseGray1
        self.header.cornerRadius = 4
        self.content.cornerRadius = 4
        self.content.borderWidth = 1
        self.content.borderColor = UIColor.baseGray1.cgColor
        
        automaticallyManagesSubnodes = true
        actionIcon.image = R.image.iconCollapse()?.fillAlpha(fillColor: AppStyle.Markdown.Color.Reference.actionIcon)
    }
    
    override func didLoad() {
        super.didLoad()
        self.caption.addTarget(self, action: #selector(didPlaylistToggle(_:)), forControlEvents: .touchUpInside)
    }
    
    
    @objc func didPlaylistToggle(_ sender: ASControlNode) {
        self.collapsed = !self.collapsed
        self.setNeedsLayout()
    }
    
    override func layout() {
        super.layout()
        self.header.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        if !self.collapsed {
            self.header.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
        
        self.content.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        caption.style.maxWidth = ASDimensionMakeWithPoints(constrainedSize.max.width-50)
        actionIcon.style.preferredSize = CGSize(width: 16, height: 9.2)
        let hSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [caption, actionIcon]
        )
        
        hSpec.style.minWidth = ASDimensionMakeWithPoints(constrainedSize.max.width)
        hSpec.style.flexGrow = 1.0
        hSpec.style.alignSelf = .stretch
        
        let vSpecContent = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 10,
            justifyContent: .start,
            alignItems: .start,
            children: nestedBlocks
        )
        
        var vSpecMainChildren: [ASLayoutElement] = [ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), child: hSpec), background: header)]
        
        if !self.collapsed {
            vSpecMainChildren.append(ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), child: vSpecContent), background: content))
        }
        
        let vSpecMain = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .start,
            children: vSpecMainChildren
        )
        
        vSpecContent.style.maxWidth = ASDimensionMakeWithPoints(constrainedSize.max.width)
        vSpecMain.style.maxWidth = ASDimensionMakeWithPoints(constrainedSize.max.width)
        
        
        return vSpecMain
    }
}

class ImageNode: ASDisplayNode {
    private let image = ASNetworkImageNode()
    private let caption = ASTextNode()
    
    public init(block: Block.Image) {
        super.init()
        self.caption.maximumNumberOfLines = 2
        self.caption.truncationMode = .byTruncatingTail
        
        self.caption.attributedText = AppStyle.Markdown.Text.Blockquote.citation(string: block.caption ?? "")
        
        self.image.url = block.src
        automaticallyManagesSubnodes = true
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.image.style.preferredSize = CGSize(width: 450, height: 200)
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: image)
    }
}

func processBlocks(blocks: [Block]) -> [ASLayoutElement] {
    var blockNodes: [ASLayoutElement] = []
    for block in blocks {
        var blockNode: BlockNode?
        
        switch block {
        case .heading(let heading):
            blockNode = BlockNode(block: HeadingNode(block: heading))
        case .paragraph(let paragraph):
            blockNode = BlockNode(block: ParagraphNode(block: paragraph))
        case .list(let list):
            blockNode = BlockNode(block: ListNode(block: list))
        case .hr(let hr):
            blockNode = BlockNode(block: HorizonalLineNode(block: hr))
        case .reference(let reference):
            blockNode = BlockNode(block: ReferenceNode(block: reference))
        case .question(let question):
            blockNode = BlockNode(block: QuestionNode(block: question))
        case .blockquote(let blockquote):
            blockNode = BlockNode(block: BlockquoteNode(block: blockquote))
        case .collapse(let collapse):
            blockNode = BlockNode(block: CollapseNode(block: collapse))
        case .image(let image):
            blockNode = BlockNode(block: ImageNode(block: image))
        default: print("")
        }
        if let blockNode = blockNode {
            blockNodes.append(blockNode)
        }
    }
    return blockNodes
}

class QuarterlyIntroductionView: ASCellNode {
    private var blockNodes: [ASLayoutElement] = []
    
    init(blocks: [Block]) {
        super.init()
        self.backgroundColor = AppStyle.Base.Color.background
        self.blockNodes = processBlocks(blocks: blocks)
        self.automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 10,
            justifyContent: .start,
            alignItems: .start,
            children: blockNodes
        )
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), child: vSpec)
    }
}
