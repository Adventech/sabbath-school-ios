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

import WidgetKit
import SwiftUI

struct TodayWidgetView : View {
    var entry: TodayWidgetProvider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.widgetRenderingMode) var widgetRenderingMode
    
    var body: some View {
        ZStack(alignment: widgetFamily == .systemLarge ? .bottomTrailing : widgetFamily == .accessoryRectangular ? .trailing : .topTrailing) {
            if widgetRenderingMode != .accented && widgetFamily != .accessoryRectangular {
                Color("WidgetBackground")
            }
            
            if widgetFamily != .accessoryRectangular {
                ZStack {
                    ZStack(alignment: .topTrailing) {
                        Image("AppLogo")
                            .resizable()
                            .padding(WidgetStyle.getLogoSize()*0.1)
                            .unredacted()
                    }
                }
                .frame(width: WidgetStyle.getLogoSize(), height: WidgetStyle.getLogoSize())
                .offset(x: WidgetStyle.getLogoOffset(widgetFamily: widgetFamily).x, y: WidgetStyle.getLogoOffset(widgetFamily: widgetFamily).y)
                .opacity(0.2)
            } else {
                VStack {
                    Image("AppLogo")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .opacity(0.3)
                        .unredacted()
                }.frame(maxHeight: .infinity)
            }
            
            VStack(alignment: .leading) {
                Text(widgetFamily == .accessoryRectangular ? entry.day.date.stringWidgetDate() : entry.day.date.stringReadDate())
                    .padding(.bottom, 0.1)
                    .font(.system(size: WidgetStyle.getStyle(widgetFamily: widgetFamily).dateFontSize, weight: .regular))
                    .lineLimit(WidgetStyle.getStyle(widgetFamily: widgetFamily).dateMaxLines)
                    .foregroundColor(Color(.label))
                
                Text(entry.lessonInfo.lesson.pdfOnly ? entry.lessonInfo.lesson.title : entry.day.title)
                    .foregroundColor(Color(.label))
                    .font(.system(size: WidgetStyle.getStyle(widgetFamily: widgetFamily).titleFontSize, weight: .bold))
                    .lineLimit(WidgetStyle.getStyle(widgetFamily: widgetFamily).titleMaxLines)
                
                if widgetFamily != .accessoryRectangular {
                    Link(destination: entry.day.webURL, label: {
                        Text("Read".localized().uppercased())
                            .padding(.vertical, 10)
                            .padding(.horizontal, 40)
                            .foregroundColor(.white)
                            .cornerRadius(11)
                            .font(.system(size: 9, weight: .bold))
                            .background {
                                Capsule()
                                    .fill(Color.baseBlue.opacity(widgetRenderingMode != .accented ? 1 : 0.2))
                            }
                    })
                }
            }.frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: widgetFamily == .accessoryRectangular ? .leading : .bottomLeading)
            .padding(.bottom, WidgetStyle.getStyle(widgetFamily: widgetFamily).contentPaddingBottom)
            .padding(.leading, WidgetStyle.getStyle(widgetFamily: widgetFamily).contentPaddingLeading)
            .padding(.trailing, WidgetStyle.getStyle(widgetFamily: widgetFamily).contentPaddingTrailing)
        }
        .widgetURL(entry.day.webURL)
        .widgetAccentable(true)
        .widgetBackground(Color.clear)
    }
}

struct TodayWidgetPreview: PreviewProvider {
    static var previews: some View {
        Group {
            TodayWidgetView(entry: TodayWidgetEntry(
                date: Date.init(),
                lessonInfo: LessonInfoWidgetProvider.placeholderLessonInfo,
                day: TodayWidgetProvider.placeholderDay
            )).previewContext(WidgetPreviewContext(family: .systemSmall))
            
            TodayWidgetView(entry: TodayWidgetEntry(
                date: Date(),
                lessonInfo: LessonInfoWidgetProvider.placeholderLessonInfo,
                day: TodayWidgetProvider.placeholderDay
            )).previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
