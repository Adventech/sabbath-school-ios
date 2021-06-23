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
import Firebase
import FirebaseAuth

struct FeaturedTodayWidgetView : View {
    var entry: TodayWidgetProvider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        ZStack(alignment: widgetFamily == .systemLarge ? .bottomTrailing : .topTrailing) {
            ZStack {
                NetworkImage(url: entry.lessonInfo.lesson.cover)
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .bottomLeading)
                Rectangle()
                        .foregroundColor(.clear)
                        .background(LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom))
            }.frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .bottomLeading)
            
            
            VStack(alignment: .leading) {
                Text(entry.day.date.stringReadDate())
                    .padding(.bottom, 0.1)
                    .font(.system(size: WidgetStyle.getStyle(widgetFamily: widgetFamily).dateFontSize, weight: .regular))
                    .lineLimit(WidgetStyle.getStyle(widgetFamily: widgetFamily).dateMaxLines)
                    .foregroundColor(Color(.white))
                    
                
                Text(entry.day.title)
                    .foregroundColor(Color(.white))
                    .font(.system(size: WidgetStyle.getStyle(widgetFamily: widgetFamily).titleFontSize, weight: .bold))
                    .lineLimit(WidgetStyle.getStyle(widgetFamily: widgetFamily).titleMaxLines)
                
                Link(destination: entry.day.webURL, label: {
                    Button(action: {}) {
                        Text("Read".localized().uppercased())
                            .padding(.top, 5)
                            .padding(.bottom, 5)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .background(Color.init(UIColor.baseBlue))
                            .foregroundColor(.white)
                            .cornerRadius(11)
                            .font(.system(size: 9, weight: .bold))
                    }
                })
            }.frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .bottomLeading)
            .padding(.bottom, WidgetStyle.getStyle(widgetFamily: widgetFamily).contentPaddingBottom)
            .padding(.leading, WidgetStyle.getStyle(widgetFamily: widgetFamily).contentPaddingLeading)
            .padding(.trailing, WidgetStyle.getStyle(widgetFamily: widgetFamily).contentPaddingTrailing)
        }.widgetURL(entry.day.webURL)
    }
}

struct FeaturedTodayWidgetPreview: PreviewProvider {
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
