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

import Foundation
import SwiftUI

struct BlockWrapperView: StyledBlock, View {
    var block: AnyBlock
    var scrollViewProxy: ScrollViewProxy?
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var inlineAudioPlaybackManager: InlineAudioPlaybackManager
    
    var parentBlock: AnyBlock?
    
    var body: some View {
        VStack (spacing: 0) {
            VStack (spacing: 0) {
                switch block.type {
                case .appeal:
                    if let appeal = block.asType(Appeal.self) {
                        BlockAppealView(block: appeal)
                    }
                case .audio:
                    if let audio = block.asType(AudioBlock.self) {
                        BlockAudioView(block: audio)
                    }
                case .blockquote:
                    if let blockquote = block.asType(Blockquote.self) {
                        BlockBlockquoteView(block: blockquote)
                    }
                case .checklist:
                    if let checklist = block.asType(Checklist.self) {
                        BlockChecklistView(block: checklist)
                    }
                case .checklistItem:
                    if let checklistItem = block.asType(ChecklistItem.self) {
                        BlockChecklistItemView(block: checklistItem)
                    }
                case .collapse:
                    if let collapse = block.asType(Collapse.self) {
                        BlockCollapseView(block: collapse)
                    }
                case .excerpt:
                    if let excerpt = block.asType(Excerpt.self) {
                        BlockExcerptView(block: excerpt)
                    }
                case .excerptItem:
                    if let excerptItem = block.asType(ExcerptItem.self) {
                        BlockExcerptItemView(block: excerptItem)
                    }
                case .heading:
                    if let heading = block.asType(Heading.self) {
                        BlockHeadingView(block: heading)
                    }
                case .hr:
                    if let hr = block.asType(Hr.self) {
                        BlockHrView(block: hr)
                    }
                case .image:
                    if let image = block.asType(BlockImage.self) {
                        BlockImageView(block: image)
                    }
                case .list:
                    if let list = block.asType(List.self) {
                        BlockListView(block: list)
                    }
                case .listItem:
                    if let listItem = block.asType(ListItem.self) {
                        BlockListItemView(block: listItem, parentBlock: parentBlock)
                    }
                case .multipleChoice:
                    if let multipleChoice = block.asType(MultipleChoice.self) {
                        BlockMultipleChoiceView(block: multipleChoice)
                    }
                case .multipleChoiceItem:
                    if let multipleChoiceItem = block.asType(MultipleChoiceItem.self) {
                        BlockMultipleChoiceItemView(block: multipleChoiceItem)
                    }
                case .paragraph:
                    if let paragraph = block.asType(Paragraph.self) {
                        BlockParagraphView(block: paragraph, parentBlock: parentBlock)
                    }
                case .poll:
                    if let poll = block.asType(Poll.self) {
                        BlockPollView(block: poll)
                    }
                case .question:
                    if let question = block.asType(Question.self) {
                        BlockQuestionView(block: question, scrollViewProxy: scrollViewProxy)
                    }
                case .reference:
                    if let reference = block.asType(Reference.self) {
                        BlockReferenceView(block: reference)
                    }
                case .table:
                    if let table = block.asType(TableBlock.self) {
                        BlockTableView(block: table)
                    }
                case .video:
                    if let video = block.asType(VideoBlock.self) {
                        BlockVideoView(block: video)
                    }
                default:
                    EmptyView()
                }
            }
            .task {
                if let audio = block.asType(AudioBlock.self), !inlineAudioPlaybackManager.audios.contains(block.id) {
                    inlineAudioPlaybackManager.audios.insert(block.id, at: 0)
                }
            }
            .padding(Styler.getBlockPadding(defaultStyles, block))
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: Styler.getBlockCornerRadius(defaultStyles, block)).fill(Styler.getBlockBackgroundColor(defaultStyles, block))
                    
                    if let background = Styler.getBlockBackgroundImage(defaultStyles, block),
                       themeManager.currentTheme == .light || (
                        colorScheme == .light && themeManager.currentTheme == .auto)
                    {
                        AsyncImage(url: background) { image in
                            image.image?
                                .resizable()
                                .scaledToFill()
                        }.background(.blue)
                        
                    }
                }
            }
        }
        .padding(Styler.getWrapperPadding(defaultStyles, block))
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: Styler.getWrapperCornerRadius(defaultStyles, block)).fill(Styler.getWrapperBackgroundColor(defaultStyles, block))
                if let background = Styler.getWrapperBackgroundImage(defaultStyles, block),
                   themeManager.currentTheme == .light || (
                    colorScheme == .light && themeManager.currentTheme == .auto)
                {
                    AsyncImage(url: background) { image in
                        image.image?
                            .resizable()
                            .scaledToFill()
                    }
                }
            }
        }
        
    }
}
