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

@MainActor @ViewBuilder
func FeedGroupItemCoverView(_ url: URL, _ dimensions: CGSize, _ placeholderColor: String? = "#cccccc", _ scaleFactor: CGFloat = 1) -> some View {
    LazyImage(url: url) { state in
        if let image = state.image {
            image.resizable().aspectRatio(contentMode: .fill)
        } else {
            Color(hex: placeholderColor ?? "#cccccc")
        }
    }
    .frame(width: dimensions.width * scaleFactor, height: dimensions.height * scaleFactor)
    .cornerRadius(6)
    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 5)
}

@ViewBuilder
func FeedGroupItemTitleView(_ title: String, _ subtitle: String?, _ dimensions: CGSize? = nil, _ direction: FeedGroupDirection, _ enlarge: Bool = false, externalURL: URL? = nil, _ scaleFactor: CGFloat = 1, _ backgroundColorEnabled: Bool = false, _ downloaded: Bool = false) -> some View {
    HStack {
        VStack(alignment: .leading, spacing: AppStyle.Feed.Spacing.betweenTitleAndSubtitle) {
            Text(AppStyle.Feed.Title.text(title, enlarge, backgroundColorEnabled))
                .lineLimit(AppStyle.Feed.Title.lineLimit)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            if let subtitle = subtitle, direction == .vertical {
                Text(AppStyle.Feed.Subtitle.text(subtitle, false, backgroundColorEnabled))
                    .lineLimit(AppStyle.Feed.Subtitle.lineLimit)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }.frame(alignment: .leading)
        
        Spacer()
        if externalURL != nil {
            Image(systemName: "arrow.up.forward.square")
                .font(.system(size: 16, weight: .light))
                .foregroundColor(.secondary)
        }
        
        if downloaded {
            VStack {
                Image(systemName: "cloud.fill")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.gray200)
                    .overlay {
                        Image(systemName: "checkmark")
                            .font(.system(size: 8, weight: .light))
                            .foregroundColor(.white | .black)
                    }
                Spacer()
            }
        }
    }.frame(width: dimensions != nil ? dimensions!.width * scaleFactor : .infinity, alignment: .leading)
}

@ViewBuilder
func FeedResourceConditionalStack<Content: View>(spacing: CGFloat, direction: FeedGroupDirection, @ViewBuilder content: () -> Content) -> some View {
    if direction == .horizontal {
        VStack(spacing: spacing, content: content)
    } else {
        HStack(spacing: spacing, content: content)
    }
}

struct FeedResourceViewBase<Content: View>: View {
    var direction: FeedGroupDirection
    var viewType: FeedGroupViewType
    var coverType: ResourceCoverType
    var showTitle: Bool = true
    
    @State var dimensions: CGSize = CGSizeMake(0.0, 0.0)
    
    @EnvironmentObject var screenSizeMonitor: ScreenSizeMonitor
    
    var content: (CGSize) -> Content
    
    var body: some View {
        content(dimensions).onAppear {
            updateDimensions()
        }.onChange(of: screenSizeMonitor.screenSize.width) { _ in
            updateDimensions()
        }
    }
    
    private func updateDimensions() {
        dimensions = AppStyle.Feed.Cover.size(
            coverType,
            direction,
            viewType,
            screenSizeMonitor.screenSize.width,
            showTitle
        )
    }
}

struct FeedResourceView: View {
    var resource: Resource
    var feedGroupViewType: FeedGroupViewType
    var feedGroupDirection: FeedGroupDirection
    var backgroundColorEnabled: Bool = false
    var showTitle: Bool = true
    var downloaded: Bool = false
    
    
    var body: some View {
        switch feedGroupViewType {
        case .banner:
            FeedResourceViewBanner(
                title: resource.title,
                subtitle: resource.subtitle,
                cover: resource.covers.landscape,
                externalURL: resource.externalURL,
                primaryColor: resource.primaryColor,
                direction: feedGroupDirection,
                backgroundColorEnabled: backgroundColorEnabled,
                showTitle: showTitle,
                downloaded: downloaded)
        case .folio:
            FeedResourceViewFolio(
                title: resource.title,
                subtitle: resource.subtitle,
                cover: resource.covers.portrait,
                externalURL: resource.externalURL,
                primaryColor: resource.primaryColor,
                direction: feedGroupDirection,
                backgroundColorEnabled: backgroundColorEnabled,
                showTitle: showTitle,
                downloaded: downloaded)
        case .square:
            FeedResourceViewSquare(
                title: resource.title,
                subtitle: resource.subtitle,
                cover: resource.covers.square,
                externalURL: resource.externalURL,
                primaryColor: resource.primaryColor,
                direction: feedGroupDirection,
                backgroundColorEnabled: backgroundColorEnabled,
                showTitle: showTitle,
                downloaded: downloaded)
        case .tile:
            FeedResourceViewTile(
                title: resource.title,
                subtitle: resource.subtitle,
                cover: resource.covers.landscape,
                externalURL: resource.externalURL,
                primaryColor: resource.primaryColor,
                direction: feedGroupDirection,
                backgroundColorEnabled: backgroundColorEnabled,
                showTitle: showTitle,
                downloaded: downloaded)
        }
    }
}

struct FeedAuthorView: View {
    var author: Author
    var feedGroupViewType: FeedGroupViewType
    var feedGroupDirection: FeedGroupDirection
    var backgroundColorEnabled: Bool = false
    var showTitle: Bool = true
    
    var body: some View {
        switch feedGroupViewType {
        case .banner:
            FeedResourceViewBanner(
                title: author.title,
                subtitle: nil,
                cover: author.covers.landscape,
                externalURL: nil,
                primaryColor: nil,
                direction: feedGroupDirection,
                backgroundColorEnabled: backgroundColorEnabled,
                showTitle: showTitle)
        case .folio:
            FeedResourceViewFolio(
                title: author.title,
                subtitle: nil,
                cover: author.covers.portrait,
                externalURL: nil,
                primaryColor: nil,
                direction: feedGroupDirection,
                backgroundColorEnabled: backgroundColorEnabled,
                showTitle: showTitle)
        case .square:
            FeedResourceViewSquare(
                title: author.title,
                subtitle: nil,
                cover: author.covers.square,
                externalURL: nil,
                primaryColor: nil,
                direction: feedGroupDirection,
                backgroundColorEnabled: backgroundColorEnabled,
                showTitle: showTitle)
        case .tile:
            FeedResourceViewTile(
                title: author.title,
                subtitle: nil,
                cover: author.covers.landscape,
                externalURL: nil,
                primaryColor: nil,
                direction: feedGroupDirection,
                backgroundColorEnabled: backgroundColorEnabled,
                showTitle: showTitle)
        }
    }
}

struct FeedCategoryView: View {
    var category: Category
    var feedGroupViewType: FeedGroupViewType
    var feedGroupDirection: FeedGroupDirection
    var backgroundColorEnabled: Bool = false
    var showTitle: Bool = true
    
    var body: some View {
        switch feedGroupViewType {
        case .banner:
            FeedResourceViewBanner(
                title: category.title,
                subtitle: nil,
                cover: category.covers.landscape,
                externalURL: nil,
                primaryColor: nil,
                direction: feedGroupDirection,
                backgroundColorEnabled: backgroundColorEnabled,
                showTitle: showTitle)
        case .folio:
            FeedResourceViewFolio(
                title: category.title,
                subtitle: nil,
                cover: category.covers.portrait,
                externalURL: nil,
                primaryColor: nil,
                direction: feedGroupDirection,
                backgroundColorEnabled: backgroundColorEnabled,
                showTitle: showTitle)
        case .square:
            FeedResourceViewSquare(
                title: category.title,
                subtitle: nil,
                cover: category.covers.square,
                externalURL: nil,
                primaryColor: nil,
                direction: feedGroupDirection,
                backgroundColorEnabled: backgroundColorEnabled,
                showTitle: showTitle)
        case .tile:
            FeedResourceViewTile(
                title: category.title,
                subtitle: nil,
                cover: category.covers.landscape,
                externalURL: nil,
                primaryColor: nil,
                direction: feedGroupDirection,
                backgroundColorEnabled: backgroundColorEnabled,
                showTitle: showTitle)
        }
    }
}
