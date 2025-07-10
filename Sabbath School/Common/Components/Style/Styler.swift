/*
 * Copyright (c) 2024 Adventech <info@adventech.io>
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

import SwiftUI

struct Styler {
    static func getStyledText(
        _ text: String,
        _ style: Style?,
        _ template: StyleTemplate,
        _ block: AnyBlock? = nil
    ) -> AttributedString {
        let themeManager = ThemeManager()
        
        var attributedString = try! AttributedString(markdown: text, including: \.sspmApp)
        var textColor = template.textColorDefault

        var textTypeface: UIFont = UIFont(name: template.textTypefaceDefault, size: template.textSizeDefault)!
        
        let allowColorChange = (themeManager.currentTheme == .light || (themeManager.currentTheme == .auto && !Preferences.darkModeEnable())) || !template.textColorThemeOverride
        
        if let style = style {
            textTypeface = Styler.getTextTypeface(style, template, nil, nil, nil, block)
            if allowColorChange {
                textColor = Styler.getTextColor(style, template, nil, nil, textColor)
            }

            if let block = block {
                textColor = Styler.getTextColor(style, template)
                
                if let nested = block.nested, nested {
                    if allowColorChange {
                        textColor = Styler.getTextColor(style, template, nil, { style in
                            return style?.blocks?.nested?.blocks?.first { $0.type == block.type }?.style.text
                        }, textColor)
                        
                        textColor = Styler.getTextColor(style, template, \.blocks?.nested?.all?.text, nil, textColor)
                    }
                } else {
                    if allowColorChange {
                        textColor = Styler.getTextColor(style, template, nil, { style in
                            return style?.blocks?.inline?.blocks?.first { $0.type == block.type }?.style.text
                        }, textColor)
                        
                        textColor = Styler.getTextColor(style, template, \.blocks?.nested?.all?.text, nil, textColor)
                    }
                }
                
                if let blockStyle = block.style {
                    if allowColorChange {
                        textColor = Styler.getTextColor(style, template, nil, { style in
                            return blockStyle.text
                        }, textColor)
                    }
                }
            }
            
            attributedString.foregroundColor = textColor
            attributedString.font = UIFontMetrics.default.scaledFont(for: textTypeface)
            
            
            if template.textOffsetEnabled {
                attributedString.baselineOffset = Styler.getTextOffset(style, template)
            }
            
            // Here order matters, so the custom attributes should be last,
            // so they are not overwritten by the whole range of attributes
            if template.textInlineStyleEnabled {
                attributedString = attributedString.annotateCustomAttributes(style, template, textTypeface, textColor, block)
            }
        } else {
            attributedString.foregroundColor = textColor
            attributedString.font = UIFontMetrics.default.scaledFont(for: textTypeface)
        }
        
        return attributedString
    }
    
    static func getTextColor(_ style: Style?, _ template: StyleTemplate, _ keyPath: KeyPath<Style, TextStyle?>? = nil, _ filter: ((_ style: Style?) -> TextStyle?)? = nil, _ defaultTextColorOverride: Color? = nil) -> Color {
        func resolveTextColor(from style: Style?) -> Color {
            guard let textColor = (filter?(style) ?? style?[keyPath: keyPath ?? template.textKeyPath])?.color else {
                return defaultTextColorOverride ?? template.textColorDefault
            }
            return Color(hex: textColor)
        }
        
        return template.textColorEnabled ? resolveTextColor(from: style) : defaultTextColorOverride ?? template.textColorDefault
    }
    
    static func getTextSize(_ style: Style?, _ template: StyleTemplate, _ keyPath: KeyPath<Style, TextStyle?>? = nil, _ filter: ((_ style: Style?) -> TextStyle?)? = nil, _ block: AnyBlock?) -> CGFloat {
        
        func resolveTextSize(_ style: Style?, _ defaultTextSize: CGFloat, _ filter: ((_ style: Style?) -> TextStyle?)? = nil) -> CGFloat {
            var target = style?[keyPath: template.textKeyPath]
            
            if filter != nil {
                target = filter?(style)
            }
            
            guard let textSize = target?.size else {
                return template.textSizeDefault
            }
            return template.textSizePoints(textSize)
        }
        
        if (!template.textSizeEnabled) {
            return template.textSizeDefault
        }
        
        var textSize = resolveTextSize(style, template.textSizeDefault)
        
        if let block = block {
            // Global default style for that type of block
            textSize = resolveTextSize(style, textSize, { style in
                return style?.blocks?.inline?.blocks?.first { $0.type == block.type }?.style.text
            })
            
            if let nested = block.nested, nested {
                textSize = resolveTextSize(style, textSize, { _ in
                    return style?.blocks?.nested?.all?.text
                })
                textSize = resolveTextSize(style, textSize, { style in
                    return style?.blocks?.nested?.blocks?.first { $0.type == block.type }?.style.text
                })
            }
            
            // Style for that specific block
            if let addedBlockStyle = block.style {
                textSize = resolveTextSize(style, textSize, { style in
                    return addedBlockStyle.text
                })
            }
        }
        
        return textSize
    }
    
    static func getTextTypeface(_ style: Style?, _ template: StyleTemplate, _ keyPath: KeyPath<Style, TextStyle?>? = nil, _ filter: ((_ style: Style?) -> TextStyle?)? = nil, _ defaultTypefaceOverride: UIFont? = nil, _ block: AnyBlock?) -> UIFont {
        let textSize = Styler.getTextSize(style, template, keyPath, filter, block)
        
        func resolveTextTypeface(from style: Style?, _ internalFilter: ((_ style: Style?) -> TextStyle?)? = nil, _ defaultTypeface: UIFont? = nil) -> UIFont {
            var target = (filter?(style) ?? style?[keyPath: keyPath ?? template.textKeyPath])
            
            if internalFilter != nil {
                target = internalFilter?(style)
            }
            
            guard let textTypeface = target?.typeface else {
                return defaultTypeface ?? defaultTypefaceOverride ?? UIFont(name: template.textTypefaceDefault, size: textSize)!
            }
            
            if let resolvedTypeface = UIFont(name: textTypeface, size: textSize) {
                return resolvedTypeface
            }

            return defaultTypeface ?? UIFont(name: template.textTypefaceDefault, size: textSize)!
        }
        
        if (!template.textTypefaceEnabled) {
            return defaultTypefaceOverride ?? UIFont(name: template.textTypefaceDefault, size: template.textSizeDefault)!
        }
        
        var textTypeface = resolveTextTypeface(from: style)
        
        if let block = block {
            // Global default style for that type of block
            
            
            if let nested = block.nested, nested {
                textTypeface = resolveTextTypeface(from: style, { style in
                    return style?.blocks?.nested?.blocks?.first { $0.type == block.type }?.style.text
                }, textTypeface)
                
                textTypeface = resolveTextTypeface(from: style, { _ in
                    return style?.blocks?.nested?.all?.text
                }, textTypeface)
            } else {
                textTypeface = resolveTextTypeface(from: style, { style in
                    return style?.blocks?.inline?.blocks?.first { $0.type == block.type }?.style.text
                }, textTypeface)
                
                textTypeface = resolveTextTypeface(from: style, { _ in
                    return style?.blocks?.inline?.all?.text
                }, textTypeface)
            }
            
            // Style for that specific block
            if let addedBlockStyle = block.style {
                textTypeface = resolveTextTypeface(from: style, { style in
                    return addedBlockStyle.text
                }, textTypeface)
                
                
            }
        }
        
        return textTypeface
    }
    
    static func getTextOffset(_ style: Style?, _ template: StyleTemplate) -> CGFloat {
        func resolveTextOffset(from style: Style?) -> CGFloat {
            guard let textOffset = style?[keyPath: template.textKeyPath]?.offset else {
                return template.textOffsetDefault
            }
            return template.textOffsetFunc(textOffset)
        }
        
        return template.textOffsetEnabled ? resolveTextOffset(from: style) : template.textOffsetDefault
    }
    
    static func findFontByFamilyNameAndWeight(familyName: String, weight: UIFont.Weight) -> UIFont? {
        let fontFamilyNames = UIFont.familyNames
        
        if fontFamilyNames.contains(familyName) {
            let fontNames = UIFont.fontNames(forFamilyName: familyName)
            
            for fontName in fontNames {
                if let customFont = UIFont(name: fontName, size: 12) {
                    let fontDescriptor = customFont.fontDescriptor.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: weight]])
                   let weightedFont = UIFont(descriptor: fontDescriptor, size: 12)
                    
                   if weightedFont.fontDescriptor.symbolicTraits.contains(.traitBold) && weight == .bold {
                       return weightedFont
                   }
                   if weight == .regular && !weightedFont.fontDescriptor.symbolicTraits.contains(.traitBold) {
                       return weightedFont
                   }
                }
            }
        }
        return nil
    }
    
    public static func convertTextAlignment(_ textAlignment: TextAlignment) -> Alignment {
        switch textAlignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }
}

extension Styler {
    static func getTextAlignment(_ style: Style?, _ template: StyleTemplate, _ block: AnyBlock? = nil) -> TextAlignment {
        func resolveTextAlignment(_ style: Style?, _ defaultTextAlignment: TextAlignment, _ filter: ((_ style: Style?) -> TextStyle?)? = nil) -> TextAlignment {
            
            var target = style?[keyPath: template.textKeyPath]
            
            if filter != nil {
                target = filter?(style)
            }
            
            guard let textAlignment = target?.align else {
                return template.textAlignmentDefault
            }
            return template.textAlignmentFunc(textAlignment)
        }
        
        if (!template.textAlignmentEnabled) {
            return template.textAlignmentDefault
        }
        
        var textAlignment = resolveTextAlignment(style, template.textAlignmentDefault)
        
        if let block = block {
            // Global default style for that type of block
            textAlignment = resolveTextAlignment(style, textAlignment, { style in
                return style?.blocks?.inline?.blocks?.first { $0.type == block.type }?.style.text
            })
            
            if let nested = block.nested, nested {
                textAlignment = resolveTextAlignment(style, textAlignment, { _ in
                    return style?.blocks?.nested?.all?.text
                })
                textAlignment = resolveTextAlignment(style, textAlignment, { style in
                    return style?.blocks?.nested?.blocks?.first { $0.type == block.type }?.style.text
                })
            }
            
            // Style for that specific block
            if let addedBlockStyle = block.style {
                textAlignment = resolveTextAlignment(style, textAlignment, { style in
                    return addedBlockStyle.text
                })
            }
        }
        
        return textAlignment
    }
    
    static func getBlockCornerRadius(_ style: Style?, _ block: AnyBlock?) -> CGFloat {
        return Styler.getCornerRadius(style, block, BlockStyleTemplate(), \.block?.rounded)
    }
    
    static func getWrapperCornerRadius(_ style: Style?, _ block: AnyBlock?) -> CGFloat {
        return Styler.getCornerRadius(style, block, BlockStyleTemplate(), \.wrapper?.rounded)
    }
    
    static func getCornerRadius(_ style: Style?, _ block: AnyBlock?, _ template: StyleTemplate, _ roundedKeyPath: KeyPath<BlockStyle, Bool?>) -> CGFloat {
        let defaultCornerRadius = template.roundedCornersDefault
        
        func resolveCornerRadius(_ style: Style?, _ defaultCornerRadius: CGFloat, _ filter: ((_ style: Style?) -> BlockStyle?)? = nil) -> CGFloat {
            var target = style?[keyPath: template.blockStyleKeyPath]
            if filter != nil {
                target = filter?(style)
            }
            guard let cornerRadius = target?[keyPath: roundedKeyPath] else {
                return defaultCornerRadius
            }
            return cornerRadius ? template.roundedCornersEnabledValue : template.roundedCornersDefault
        }
        
        if (!template.roundedCornersEnabled) {
            return template.roundedCornersDefault
        }
        
        var cornerRadius = resolveCornerRadius(style, defaultCornerRadius)
        
        if let block = block {
            
            // Global default style for that type of block
            cornerRadius = resolveCornerRadius(style, cornerRadius, { style in
                return style?.blocks?.inline?.blocks?.first { $0.type == block.type }?.style
            })
            
            if let nested = block.nested, nested {
                cornerRadius = resolveCornerRadius(style, cornerRadius, { _ in
                    return style?.blocks?.nested?.all
                })
                
                cornerRadius = resolveCornerRadius(style, cornerRadius, { style in
                    return style?.blocks?.nested?.blocks?.first { $0.type == block.type }?.style
                })
            }
            
            // Style for that specific block
            if let addedBlockStyle = block.style {
                cornerRadius = resolveCornerRadius(style, cornerRadius, { style in
                    return addedBlockStyle
                })
            }
        }
        return cornerRadius
    }
    
    static func getBlockPadding(_ style: Style?, _ block: AnyBlock?) -> EdgeInsets {
        return Styler.getPadding(style, block, BlockStyleTemplate(), \.block?.padding)
    }
    
    static func getWrapperPadding(_ style: Style?, _ block: AnyBlock?) -> EdgeInsets {
        return Styler.getPadding(style, block, BlockStyleTemplate(), \.wrapper?.padding)
    }
    
    static func getPadding(_ style: Style?, _ block: AnyBlock?, _ template: StyleTemplate, _ paddingKeyPath: KeyPath<BlockStyle, SpacingStyle?>) -> EdgeInsets {
        let defaultPadding = template.paddingDefault
        
        func resolvePadding(_ style: Style?, _ defaultPadding: EdgeInsets, _ filter: ((_ style: Style?) -> BlockStyle?)? = nil) -> EdgeInsets {
            
            var target = style?[keyPath: template.blockStyleKeyPath]
            
            if filter != nil {
                target = filter?(style)
            }
            
            guard let padding = target?[keyPath: paddingKeyPath] else {
                return defaultPadding
            }
            
            return EdgeInsets(
                top: padding.top.flatMap { template.paddingFunc($0) } ?? defaultPadding.top,
                leading: padding.start.flatMap { template.paddingFunc($0) } ?? defaultPadding.leading,
                bottom: padding.bottom.flatMap { template.paddingFunc($0) } ?? defaultPadding.bottom,
                trailing: padding.end.flatMap { template.paddingFunc($0) } ?? defaultPadding.trailing
            )
        }
        
        if (!template.paddingEnabled) {
            return template.paddingDefault
        }
        
        var padding = resolvePadding(style, defaultPadding)
        
        if let block = block {
            // Global default style for that type of block (inline)
            padding = resolvePadding(style, padding, { style in
                return style?.blocks?.inline?.blocks?.first { $0.type == block.type }?.style
            })
            
            if let nested = block.nested, nested {
                padding = resolvePadding(style, padding, { _ in
                    return style?.blocks?.nested?.all
                })
                
                padding = resolvePadding(style, padding, { style in
                    return style?.blocks?.nested?.blocks?.first { $0.type == block.type }?.style
                })
            }
            
            // Style for that specific block
            if let addedBlockStyle = block.style {
                padding = resolvePadding(style, padding, { style in
                    return addedBlockStyle
                })
            }
        }
        
        return padding
    }
    
    static func getBlockBackgroundColor(_ style: Style?, _ block: AnyBlock?, _ allowColorChange: Bool? = nil) -> Color {
        return Styler.getBackgroundColor(style, block, BlockStyleTemplate(), \.block?.backgroundColor, allowColorChange)
    }
    
    static func getWrapperBackgroundColor(_ style: Style?, _ block: AnyBlock?, _ allowColorChange: Bool? = nil) -> Color {
        return Styler.getBackgroundColor(style, block, BlockStyleTemplate(), \.wrapper?.backgroundColor, allowColorChange)
    }
    
    static func getBackgroundColor(_ style: Style?, _ block: AnyBlock?, _ template: StyleTemplate, _ backgroundColorKeyPath: KeyPath<BlockStyle, String?>, _ allowColorChange: Bool? = nil) -> Color {
        let defaultBackgroundColor = template.backgroundColorDefault
        let themeManager = ThemeManager()
        
        func resolveBackgroundColor(_ style: Style?, _ defaultBackgroundColor: Color, _ filter: ((_ style: Style?) -> BlockStyle?)? = nil) -> Color {
            var target = style?[keyPath: template.blockStyleKeyPath]
            
            if filter != nil {
                target = filter?(style)
            }
            
            guard let hexString = target?[keyPath: backgroundColorKeyPath],
                  !hexString.isEmpty else {
                return defaultBackgroundColor
            }
            return Color(hex: hexString)
        }
        
        if (!template.backgroundColorEnabled) {
            return template.backgroundColorDefault
        }
        
        var backgroundColor = resolveBackgroundColor(style, defaultBackgroundColor)
        
        let allowColorChange = allowColorChange ?? (themeManager.currentTheme == .light || (themeManager.currentTheme == .auto && !Preferences.darkModeEnable()))
        
        if let block = block {
            // Global default style for that type of block
            backgroundColor = resolveBackgroundColor(style, backgroundColor, { style in
                return style?.blocks?.inline?.blocks?.first { $0.type == block.type }?.style
            })
            
            if let nested = block.nested, nested {
                backgroundColor = resolveBackgroundColor(style, backgroundColor, { _ in
                    return style?.blocks?.nested?.all
                })
                
                backgroundColor = resolveBackgroundColor(style, backgroundColor, { style in
                    return style?.blocks?.nested?.blocks?.first { $0.type == block.type }?.style
                })
            }
            
            // Style for that specific block
            if let addedBlockStyle = block.style {
                backgroundColor = resolveBackgroundColor(style, backgroundColor, { style in
                    return addedBlockStyle
                })
            }
        }
        
        if !allowColorChange && (backgroundColor != template.backgroundColorDefault) {
            return AppStyle.Block.genericBackgroundColorForInteractiveBlock(theme: themeManager.currentTheme)
        }
        
        return backgroundColor
    }
    
    static func getBlockBackgroundImage(_ style: Style?, _ block: AnyBlock?) -> URL? {
        return Styler.getBlockBackgroundImage(style, block, BlockStyleTemplate(), \.block?.backgroundImage)
    }
    
    static func getWrapperBackgroundImage(_ style: Style?, _ block: AnyBlock?) -> URL? {
        return Styler.getBlockBackgroundImage(style, block, BlockStyleTemplate(), \.wrapper?.backgroundImage)
    }
    
    static func getBlockBackgroundImage(_ style: Style?, _ block: AnyBlock?, _ template: StyleTemplate, _ backgroundColorKeyPath: KeyPath<BlockStyle, URL?>) -> URL? {
        let defaultBackgroundImage = template.backgroundImageDefault
        
        func resolveBackgroundImage(_ style: Style?, _ defaultBackgroundImage: URL?, _ filter: ((_ style: Style?) -> BlockStyle?)? = nil) -> URL? {
            
            var target = style?[keyPath: template.blockStyleKeyPath]
            
            if filter != nil {
                target = filter?(style)
            }
            
            guard let url = target?[keyPath: backgroundColorKeyPath] else {
                return defaultBackgroundImage
            }
            return url
        }
        
        if (!template.backgroundImageEnabled) {
            return template.backgroundImageDefault
        }
        
        var backgroundImage = resolveBackgroundImage(style, defaultBackgroundImage)
        
        if let block = block {
            // Global default style for that type of block
            backgroundImage = resolveBackgroundImage(style, backgroundImage, { style in
                return style?.blocks?.inline?.blocks?.first { $0.type == block.type }?.style
            })
            
            if let nested = block.nested, nested {
                backgroundImage = resolveBackgroundImage(style, backgroundImage, { _ in
                    return style?.blocks?.nested?.all
                })
                
                backgroundImage = resolveBackgroundImage(style, backgroundImage, { style in
                    return style?.blocks?.nested?.blocks?.first { $0.type == block.type }?.style
                })
            }
            
            // Style for that specific block
            if let addedBlockStyle = block.style {
                backgroundImage = resolveBackgroundImage(style, backgroundImage, { style in
                    return addedBlockStyle
                })
            }
        }
        
        return backgroundImage
    }
}

extension AttributedString {
    func annotateCustomAttributes(_ style: Style?, _ template: StyleTemplate, _ defaultTypefaceF: UIFont? = nil, _ defaultColorF: Color? = nil, _ block: AnyBlock?) -> AttributedString {
        var attrString = self
        
        let defaultTypeface = defaultTypefaceF ?? Styler.getTextTypeface(style, template, nil, nil, nil, block)
        let defaultTextSize = defaultTypefaceF?.pointSize ?? Styler.getTextSize(style, template, nil, nil, block)
        let defaultColor = defaultColorF
        
        for run in attrString.runs {
            var inlineTextSize = defaultTextSize
            
            if (template.textLinksEnabled && run.link != nil) {
                attrString[run.range].font = UIFontMetrics.default.scaledFont(for: UIFont(name: defaultTypeface.fontName, size: defaultTextSize+0.001)!.withSize(defaultTextSize+0.001))
                
                if let url = run.link?.absoluteString, url.contains("sspmCompletion") {
                    attrString[run.range].underlineStyle = Text.LineStyle(pattern: .solid, color: AppStyle.Block.Completion.underlineColor())
                    attrString[run.range].backgroundColor = AppStyle.Block.Completion.backgroundColor()
                } else {
                    attrString[run.range].underlineStyle = Text.LineStyle(pattern: .solid)
                }
                
                if let defaultColor = defaultColor {
                    attrString[run.range].foregroundColor = defaultColor
                }
                
            } else {
                if run.inlinePresentationIntent == .stronglyEmphasized ||
                    run.inlinePresentationIntent == .emphasized {

                    if let boldFont = Styler.findFontByFamilyNameAndWeight(
                        familyName: defaultTypeface.familyName,
                        weight: run.inlinePresentationIntent == .stronglyEmphasized ? .bold : .regular
                    ) {
                        attrString[run.range].font = UIFontMetrics.default.scaledFont(for: boldFont.withSize(inlineTextSize+0.001))
                    } else {
                        attrString[run.range].font = UIFontMetrics.default.scaledFont(for: UIFont(name: defaultTypeface.fontName, size: inlineTextSize+0.002)!.withSize(inlineTextSize+0.002))
                    }
                } else {
                    attrString[run.range].font = UIFontMetrics.default.scaledFont(for: UIFont(name: defaultTypeface.fontName, size: inlineTextSize+0.003)!.withSize(inlineTextSize+0.003))
                }
                
                if let defaultColor = defaultColor {
                    attrString[run.range].foregroundColor = defaultColor
                }
            }
            
            if  let style = run.style,
                let text = style.text {
                
                let themeManager = ThemeManager()
                
                let allowColorChange = (themeManager.currentTheme == .light || (themeManager.currentTheme == .auto && !Preferences.darkModeEnable())) || !template.textColorThemeOverride
                
                if let offset = text.offset, template.textOffsetEnabled == true {
                    attrString[run.range].baselineOffset = template.textOffsetFunc(offset)
                    inlineTextSize /= 1.5
                }
                
                if let size = text.size, template.textSizeEnabled {
                    inlineTextSize = template.textSizePoints(size)
                }
                
                if let typeface = text.typeface,
                   let inlineTypeface = UIFont(name: typeface, size: inlineTextSize),
                   template.textTypefaceEnabled == true {
                    attrString[run.range].font = UIFontMetrics.default.scaledFont(for: UIFont(name: inlineTypeface.fontName, size: inlineTextSize+0.004)!.withSize(inlineTextSize+0.004))
                    
                } else if inlineTextSize != defaultTextSize {
                    // Case where text size is set but typeface is not specified
                    attrString[run.range].font = UIFontMetrics.default.scaledFont(for: UIFont(name: defaultTypeface.fontName, size: inlineTextSize+0.005)!.withSize(inlineTextSize+0.005))
                }
                
                if let color = text.color, template.textColorEnabled, allowColorChange {
                    // Case where color is set in the inline markdown attributes
                    attrString[run.range].foregroundColor = Color(UIColor(hex: color))
                }
            }
        }
        
        return attrString
    }
}
