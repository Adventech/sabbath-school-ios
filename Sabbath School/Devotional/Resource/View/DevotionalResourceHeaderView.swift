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

class DevotionalResourceViewHeader: ASCellNode {
    enum HeaderStyle {
        case color
        case cover
        case splash
    }
    
    public var headerStyle: HeaderStyle = .color
    private let resource: Resource
    public let title = ASTextNode()
    private let subtitle = ASTextNode()
    private let background = ASDisplayNode()
    public let splash = ASNetworkImageNode()
    private let cover: RoundedCornersImage
    private let infiniteColor = ASDisplayNode()
    
    public let openButton = OpenButtonNode()
    private let openButtonTitle = ASTextNode()
    private let openButtonSubtitle = ASTextNode()
    private let openButtonIcon = ASImageNode()
    
    private let openButtonIndex: String
    private let openButtonTitleText: String
    private let openButtonSubtitleText: String?
    
    public var delegate: DevotionalResourceDetailDelegate?
    
    var initialSplashHeight: CGFloat = 0
    
    init(resource: Resource, openButtonIndex: String, openButtonTitleText: String, openButtonSubtitleText: String? = nil) {
        self.resource = resource
        self.openButtonIndex = openButtonIndex
        self.openButtonTitleText = openButtonTitleText
        self.openButtonSubtitleText = openButtonSubtitleText
        cover = RoundedCornersImage(
            imageURL: resource.cover,
            corner: 4.0,
            size: CGSize(width: 150, height: 225),
            backgroundColor: UIColor(hex: resource.primaryColorDark)
        )
        super.init()
        title.attributedText = AppStyle.Devo.Text.resourceDetailTitleForColor(string: resource.title, textColor: UIColor(hex: resource.textColor))
        openButtonTitle.truncationMode = .byTruncatingTail
        subtitle.attributedText = AppStyle.Devo.Text.resourceDetailSubtitleForColor(string: resource.subtitle ?? "", textColor: UIColor(hex: resource.textColor).withAlphaComponent(0.7))
        
        cover.shadowColor = UIColor(hex: resource.primaryColorDark).cgColor
        cover.shadowOffset = CGSize(width: 0, height: 2)
        cover.shadowRadius = 10
        cover.shadowOpacity = 0.9
        cover.clipsToBounds = false
        
        splash.url = resource.splash
        splash.contentMode = .scaleAspectFill
        
        openButtonTitle.attributedText = AppStyle.Devo.Text.openButtonTitle(string: openButtonTitleText)
        openButtonSubtitle.attributedText = AppStyle.Devo.Text.openButtonSubtitle(string: openButtonSubtitleText ?? "")
        openButtonTitle.maximumNumberOfLines = 1
        openButtonSubtitle.maximumNumberOfLines = 1
        openButton.backgroundColor = .white | .black
        openButton.cornerRadius = 6
        openButton.shadowColor = (UIColor(white: 0, alpha: 0.6) | .gray).cgColor
        openButton.shadowOffset = CGSize(width: 0, height: 2)
        openButton.shadowRadius = 10
        openButton.shadowOpacity = 0.5
        openButtonIcon.image = R.image.iconMore()?.fillAlpha(fillColor: AppStyle.Quarterly.Color.seeAllIcon)
        
        openButton.addTarget(self, action: #selector(self.openButtonAction(sender:)), forControlEvents: .touchUpInside)
        
        addSubnode(splash)
        addSubnode(background)
        addSubnode(cover)
        addSubnode(title)
        addSubnode(subtitle)
        addSubnode(openButton)
        addSubnode(openButtonTitle)
        addSubnode(openButtonSubtitle)
        addSubnode(openButtonIcon)
        
        insertSubnode(infiniteColor, at: 0)
        
        clipsToBounds = false
        
        if resource.cover != nil {
            headerStyle = .cover
        }

        if resource.splash != nil {
            headerStyle = .splash
            clipsToBounds = true
        }
        
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        
    }
    
    @objc func openButtonAction(sender: ASButtonNode) {
        delegate?.didSelectResource(index: openButtonIndex)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let vSpec = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 10,
            justifyContent: .end,
            alignItems: .center,
            children: [title]
        )
        
        
        
        if resource.subtitle != nil {
            vSpec.children?.append(subtitle)
        }
        
        var openButtonChildren: [ASLayoutElement] = [openButtonTitle]
        
        openButtonTitle.style.maxWidth = ASDimensionMake(constrainedSize.max.width)
        
        if openButtonSubtitleText != nil {
            openButtonChildren.insert(openButtonSubtitle, at: 0)
        }
        
        let openButtonTextSpec = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 5,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [
                ASStackLayoutSpec(
                    direction: .vertical,
                    spacing: 5,
                    justifyContent: .start,
                    alignItems: .start,
                    children: openButtonChildren
                )
                , openButtonIcon]
        )
        
        openButtonTitle.style.maxWidth = ASDimensionMakeWithPoints(constrainedSize.max.width * 0.55)
        openButtonSubtitle.style.maxWidth = ASDimensionMakeWithPoints(constrainedSize.max.width * 0.55)
        
        openButtonTextSpec.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMakeWithFraction(0.75), height: ASDimensionMake(.auto, 0))
        
        let openButtonOverlay = ASBackgroundLayoutSpec(
            child: ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15), child: openButtonTextSpec),
            background: openButton)
        
        openButtonOverlay.style.spacingBefore = 20
        
        vSpec.children?.append(openButtonOverlay)
        
        if headerStyle == .splash {
            title.style.spacingBefore = 100
            splash.style.preferredSize = CGSize(width: constrainedSize.max.width, height: UIScreen.main.bounds.height / 1.7)
            title.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMakeWithPoints(constrainedSize.max.width), height: ASDimensionMake(.auto, 0))
            subtitle.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMakeWithPoints(constrainedSize.max.width), height: ASDimensionMake(.auto, 0))
            vSpec.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionMakeWithPoints(constrainedSize.max.width), height: ASDimensionMake(.auto, 0))
            
            let splashOverlay = ASBackgroundLayoutSpec(
                child: ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 20, bottom: 40, right: 20), child: vSpec),
                background: background)
            
            let relativeSpec = ASRelativeLayoutSpec(
                horizontalPosition: .center,
                verticalPosition: .end,
                sizingOption: [],
                child: splashOverlay)

            let overlaySpec = ASOverlayLayoutSpec(
                child: splash,
                overlay: relativeSpec)

            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: overlaySpec)
        }
        
        if headerStyle == .cover {
            cover.style.preferredSize = CGSize(width: 150, height: 225)
            cover.style.spacingAfter = 20
            cover.style.spacingBefore = 100
            vSpec.children?.insert(cover, at: 0)
        }
        
        if headerStyle == .color {
            title.style.spacingBefore = 150
        }
        
        let mainSpec = ASBackgroundLayoutSpec(
            child: ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 20, bottom: 40, right: 20), child: vSpec),
            background: background
        )
        
        return mainSpec
    }
    
    override func didLoad() {
        self.view.directionalLayoutMargins = .zero
        initialSplashHeight = splash.calculatedSize.height
        infiniteColor.backgroundColor = UIColor(hex: resource.primaryColor)
        super.didLoad()
        
        if headerStyle == .splash {
            if UIAccessibility.isReduceTransparencyEnabled {
                background.gradient(
                    from: UIColor.white.withAlphaComponent(0),
                    to: UIColor(hex: resource.primaryColorDark)
                )
            } else {
                background.gradientBlur(
                    from: UIColor.white.withAlphaComponent(0),
                    to: UIColor(hex: resource.primaryColorDark),
                    locations: [0.0, 0.75, 1],
                    backgroundColor: UIColor(hex: resource.primaryColorDark)
                )
            }
        }
    }
    
    override func layout() {
        super.layout()
        if headerStyle != .splash {
            infiniteColor.frame = CGRect(x: 0, y: calculatedSize.height-2000, width: calculatedSize.width, height: 2000)
        }
    }
}
