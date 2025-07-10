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
import NukeUI

struct ConditionalBackground: ViewModifier {
    var hex: String?

    func body(content: Content) -> some View {
        if let hex = hex {
            content.background(Color(hex: hex))
        } else {
            content
        }
    }
}

extension View {
    func conditionalBackground(hex: String?) -> some View {
        self.modifier(ConditionalBackground(hex: hex))
    }
}


@ViewBuilder
func FeedGroupConditionalStack<Content: View>(
    feedGroupDirection: FeedGroupDirection,
    @ViewBuilder content: () -> Content) -> some View {
        
    if feedGroupDirection == .horizontal {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: AppStyle.Feed.Spacing.betweenResources, content: content)
                .targetLayout(safeAreaPadding: AppStyle.Feed.Spacing.horizontalPadding)
        }
        .scrollViewPaging(safeAreaPadding: AppStyle.Feed.Spacing.horizontalPadding)
        
    } else {
        VStack(spacing: AppStyle.Feed.Spacing.betweenResources, content: content)
            .padding(AppStyle.Feed.Spacing.horizontalPadding)
    }
}

@ViewBuilder
func ResourceLink<Destination: View, Content: View>(
    externalURL: URL?,
    destination: Destination,
    destinationAlternate: ((String) -> AnyView)? = nil,
    documentIndex: String? = nil,
    @ViewBuilder content: @escaping () -> Content
) -> some View {
    if let url = externalURL {
        Link(destination: url) {
            content()
        }
    } else if let documentIndex = documentIndex, let destinationAlternate = destinationAlternate {
        NavigationLink {
            destinationAlternate(documentIndex)
        } label: {
            content()
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    } else {
        NavigationLink {
            destination
        } label: {
            content()
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct FeedGroupView: View {
    var resourceType: ResourceType
    var feedGroup: AnyFeedGroup
    var displayFeedGroupTitle: Bool = true
    var prefix: String = ""
    
    @EnvironmentObject var downloadManager: DownloadManager
    
    var body: some View {
        VStack(spacing: 0) {
            if (displayFeedGroupTitle
                && (feedGroup.title != nil || feedGroup.seeAll != nil)
            ) {
                HStack {
                    if let title = feedGroup.title, displayFeedGroupTitle {
                        Text(AppStyle.Feed.GroupTitle.text(title, feedGroup.backgroundColor != nil))
                    }
                    Spacer()
                    if let seeAll = feedGroup.seeAll {
                        NavigationLink {
                            FeedSeeAllView(resourceType: resourceType, feedGroupId: feedGroup.id, prefix: prefix)
                        } label: {
                            Text(AppStyle.Feed.SeeAllTitle.text("\(seeAll) ›", feedGroup.backgroundColor != nil))
                        }.buttonStyle(.plain)
                    }
                    
                }
                .padding(AppStyle.Feed.Spacing.horizontalPadding)
            }
            if let resources = feedGroup.asType(FeedGroupResources.self)?.resources {
                resourcesFeedGroupView(resources)
            }
            
            if let authors = feedGroup.asType(FeedGroupAuthors.self)?.authors {
                authorsFeedGroupView(authors)
            }
            
            if let categories = feedGroup.asType(FeedGroupCategories.self)?.categories {
                categoriesFeedGroupView(categories)
            }
        }
        .padding(0)
        .conditionalBackground(hex: feedGroup.backgroundColor)
    }
    
    func resourcesFeedGroupView(_ resources: [Resource]) -> some View {
        VStack {
            FeedGroupConditionalStack(feedGroupDirection: feedGroup.direction) {
                ForEach(resources) { resource in
                    ResourceLink(
                        externalURL: resource.externalURL,
                        destination: ResourceView(resourceIndex: resource.index),
                        destinationAlternate: { index in
                            AnyView(DocumentView(documentIndex: index))
                        },
                        documentIndex: resource.documentIndex
                    ) {
                        FeedResourceView(resource: resource, feedGroupViewType: feedGroup.view, feedGroupDirection: feedGroup.direction, backgroundColorEnabled: feedGroup.backgroundColor != nil, showTitle: feedGroup.showTitle != false, downloaded: downloadManager.downloadItems[resource.id]?.isCompleted() == true)
                    }
                    .contextMenu {
                        NavigationLink {
                            if let documentIndex = resource.documentIndex {
                                DocumentView(documentIndex: documentIndex)
                            } else {
                                ResourceView(resourceIndex: resource.index)
                            }
                        } label: {
                            Text("Read".localized())
                        }
                        Divider()
                        
                        ShareLink(
                            item: URL(string: "\(Constants.API.HOST)/resources/\(resource.index)")!,
                            subject: Text(resource.title)
                        ) {
                            Text("Share".localized())
                        }
                    } preview: {
                        HStack {
                            LazyImage(url: resource.covers.portrait) { image in
                                image
                                    .image?
                                    .resizable()
                                    .scaledToFill()
                            }
                            .cornerRadius(5)
                            .frame(width: 80, height: 100)
                            .frame(minWidth: 80, minHeight: 100)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                if let subtitle = resource.subtitle {
                                    Text(subtitle.uppercased())
                                        .font(.custom("Lato-Bold", size: 10))
                                        .foregroundColor((.black | .white).opacity(0.5))
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                Text(resource.title)
                                    .font(.custom("Lato-Bold", size: 18))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 220)
                        .frame(maxHeight: 220)
                    }
                }
            }
        }
        .padding(0)
    }
    
    func authorsFeedGroupView(_ authors: [Author]) -> some View {
        VStack {
            FeedGroupConditionalStack(feedGroupDirection: feedGroup.direction) {
                ForEach(authors) { author in
                    NavigationLink {
                        AuthorFeedView(authorId: author.id)
                    } label: {
                        FeedAuthorView(author: author, feedGroupViewType: feedGroup.view, feedGroupDirection: feedGroup.direction, backgroundColorEnabled: feedGroup.backgroundColor != nil, showTitle: feedGroup.showTitle != false)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(0)
    }
    
    func categoriesFeedGroupView(_ categories: [Category]) -> some View {
        VStack {
            FeedGroupConditionalStack(feedGroupDirection: feedGroup.direction) {
                ForEach(categories) { category in
                    NavigationLink {
                        CategoryFeedView(categoryId: category.id)
                    } label: {
                        FeedCategoryView(category: category, feedGroupViewType: feedGroup.view, feedGroupDirection: feedGroup.direction, backgroundColorEnabled: feedGroup.backgroundColor != nil, showTitle: feedGroup.showTitle != false)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(0)
    }
}
