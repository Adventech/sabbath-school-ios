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

struct LessonInfoWidgetView : View {
    var entry: LessonInfoWidgetProvider.Entry
    let today = Date()
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color("WidgetBackground")
            ZStack {
                ZStack(alignment: .center) {
                    Image("AppLogo")
                        .resizable()
                        .padding(WidgetStyle.getLogoSize()*0.1)
                        .unredacted()
                }
            }
            .frame(width: 80, height: 80)
            .opacity(0.1)
            
            VStack(alignment: .leading) {
                HStack() {
                    NetworkImage(url: entry.quarterly.cover)
                        .frame(height: 70)
                        .cornerRadius(4)
                    VStack(alignment: .leading) {
                        Text(entry.quarterly.title)
                            .foregroundColor(Color(.label))
                            .font(.system(size: 16, weight: .bold))
                            .lineLimit(2)
                        Text(entry.lessonInfo.lesson.title)
                            .font(.system(size: 13, weight: .regular))
                            .padding(.top, 1)
                            .lineLimit(1)
                            .foregroundColor(Color(.label))
                            .opacity(0.7)
                    }
                    
                }
                .padding(.leading, 15)
                .padding(.trailing, 15)
                
                Divider()
                    .padding(.top, 15)
                    .padding(.bottom, 10)
                
                VStack() {
                    ForEach(entry.lessonInfo.days[...6], id: \.index) { day in
                        VStack() {
                            Spacer()
                            HStack() {
                                Link(destination: day.webURL, label: {
                                    Text(day.title)
                                        .font(.system(size: 12, weight: (Calendar.current.compare(self.today, to: day.date, toGranularity: .day) == .orderedSame) ? .bold : .regular))
                                        .lineLimit(1)
                                        .opacity((Calendar.current.compare(self.today, to: day.date, toGranularity: .day) == .orderedSame) ? 1 : 0.7)
                                        .fixedSize(horizontal: false, vertical: true)
                                })
                                    
                                Spacer()
                                Link(destination: day.webURL, label: {
                                    Text(day.date.stringWidgetDate())
                                        .font(.system(size: 12, weight: .regular))
                                        .lineLimit(1)
                                        .opacity(0.7)
                                        .fixedSize(horizontal: false, vertical: true)
                                })
                            }
                            Spacer()
                            if entry.lessonInfo.days[...6].last!.index != day.index {
                                Divider()
                            }
                        }.frame(minWidth: 0,
                                maxWidth: .infinity,
                                minHeight: 0,
                                maxHeight: .infinity)
                            
                        }
                    }.frame(minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: .infinity,
                            alignment: .center)
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
            }.frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .topLeading)
            .padding(.top, 15)
            .padding(.bottom, 15)
        }.widgetURL(entry.quarterly.webURL)
    }
}

struct LessonInfoWidgetPreview: PreviewProvider {
    static var previews: some View {
        Group {
            LessonInfoWidgetView(entry: LessonInfoWidgetEntry(
                date: Date.init(),
                quarterly: LessonInfoWidgetProvider.placeholderQuarterly,
                lessonInfo: LessonInfoWidgetProvider.placeholderLessonInfo
            ))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
