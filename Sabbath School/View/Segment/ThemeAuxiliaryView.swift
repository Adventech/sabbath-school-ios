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

struct ThemeAuxiliaryView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                Group {
                    Spacer()
                    Button (action: {
                        themeManager.setTheme(to: .light)
                    }) {
                        Text("Light".localized())
                            .font(Font.custom("Lato-Regular", size: 16))
                            .lineLimit(1)
                            .padding(10)
                            .fontWeight(themeManager.currentTheme == .light ? .bold : .regular)
                    }.accentColor(.black | .white)
                }
                Group {
                    Spacer()
                    Divider()
                }
                Group {
                    Spacer()
                    Button (action: {
                        themeManager.setTheme(to: .sepia)
                    }) {
                        Text("Sepia".localized())
                            .font(Font.custom("Lato-Regular", size: 16))
                            .lineLimit(1)
                            .padding(10)
                            .fontWeight(themeManager.currentTheme == .sepia ? .bold : .regular)
                    }.accentColor(.black | .white)
                }
                Group {
                    Spacer()
                    Divider()
                }
                Group {
                    Spacer()
                    Button (action: {
                        themeManager.setTheme(to: .dark)
                    }) {
                        Text("Dark".localized())
                            .font(Font.custom("Lato-Regular", size: 16))
                            .lineLimit(1)
                            .padding(10)
                            .fontWeight(themeManager.currentTheme == .dark ? .bold : .regular)
                    }.accentColor(.black | .white)
                }
                Group {
                    Spacer()
                    Divider()
                }
                Group {
                    Spacer()
                    Button (action: {
                        themeManager.setTheme(to: .auto)
                    }) {
                        Text("Auto".localized())
                            .font(Font.custom("Lato-Regular", size: 16))
                            .lineLimit(1)
                            .padding(10)
                            .fontWeight(themeManager.currentTheme == .auto ? .bold : .regular)
                    }.accentColor(.black | .white)
                }
                Spacer()
            }
            .fixedSize(horizontal: false, vertical: true)

            Divider()
            HStack {
                Group {
                    Spacer()
                    Button (action: {
                        themeManager.setTypeface(to: .lato)
                    }) {
                        Text("Lato".localized())
                            .font(Font.custom("Lato-Regular", size: 16))
                            .lineLimit(1)
                            .padding(10)
                            .fontWeight(themeManager.currentTypeface == .lato ? .bold : .regular)
                    }.accentColor(.black | .white)
                }
                Group {
                    Spacer()
                    Button (action: {
                        themeManager.setTypeface(to: .andada)
                    }) {
                        Text("Andada".localized())
                            .font(Font.custom("Lora-Regular", size: 16))
                            .lineLimit(1)
                            .padding(10)
                            .fontWeight(themeManager.currentTypeface == .andada ? .bold : .regular)
                    }.accentColor(.black | .white)
                }
                Group {
                    Spacer()
                    Button (action: {
                        themeManager.setTypeface(to: .ptSans)
                    }) {
                        Text("PT Sans".localized())
                            .font(Font.custom("PTSans-Regular", size: 16))
                            .lineLimit(1)
                            .padding(10)
                            .fontWeight(themeManager.currentTypeface == .ptSans ? .bold : .regular)
                    }.accentColor(.black | .white)
                }
                Group {
                    Spacer()
                    Button (action: {
                        themeManager.setTypeface(to: .ptSerif)
                    }) {
                        Text("PT Serif".localized())
                            .font(Font.custom("PTSerif-Regular", size: 16))
                            .lineLimit(1)
                            .padding(10)
                            .fontWeight(themeManager.currentTypeface == .ptSerif ? .bold : .regular)
                    }.accentColor(.black | .white)
                }
                Spacer()
            }
            .fixedSize(horizontal: false, vertical: true)
            
            Divider()
            HStack {
                Group {
                    Spacer()
                    Button (action: {
                        themeManager.decreaseSize()
                    }) {
                        Image(systemName: "textformat.size.smaller")
                            .padding(10)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .accentColor(.black | .white)
                }
                Group {
                    Spacer()
                    Divider()
                }
                Group {
                    Spacer()
                    Button (action: {
                        themeManager.increaseSize()
                    }) {
                        Image(systemName: "textformat.size.larger")
                            .padding(10)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .accentColor(.black | .white)
                }
                Spacer()
            }
            .contextMenu {
                Button(action: {
                    themeManager.setSize(to: .medium)
                }) {
                   Image(systemName: "arrow.counterclockwise").padding(10)
               }.accentColor(.black | .white)
            }
            .fixedSize(horizontal: false, vertical: true)
            Divider()
            HStack {
                Spacer()
                ForEach(0..<5, id: \.self) { iterator in
                    Circle()
                        .fill(AppStyle.ThemeAux.sizeIndicator(active: themeManager.getSizeNumber() > iterator))
                        .frame(width: 5, height: 5)
                }
                Spacer()
            }
            .padding(10)
        }.modifier(ReadingOptionsBackground()).frame(maxWidth: 400)
    }
}
