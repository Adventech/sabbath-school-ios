/*
 * Copyright (c) 2023 Adventech <info@adventech.io>
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
import Kingfisher
import SDWebImageSwiftUI
import Combine
import Foundation

enum TabMenu: Int {
    case videos = 0
    case language = 1
}

struct ContentView: View {
    
    @ObservedObject var dataProvider = DataProvider()
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    @State var image: UIImage = UIImage()
    
    @State private var tabSelection = TabMenu.videos.rawValue
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .renderingMode(.original)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
            .clipped()
            .cornerRadius(10)
            .shadow(radius: 5)
            .overlay {
                NavigationView {
                    TabView(selection: $tabSelection) {
                        VStack(spacing: 0) {
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: 16) {
                                    ForEach(dataProvider.sections) { section in
                                        VideoListView(section: section, didTapLink: { backgroundImage in
                                            imageLoader.loadImage(urlString: backgroundImage.thumbnail)
                                        })
                                    }
                                    .animation(.default)
                                }
                                .padding()
                            }
                        }
                        .tabItem {
                            HStack {
                                Image(systemName: "list.bullet.below.rectangle")
                                Text(NSLocalizedString("videos", comment: ""))
                            }
                        }.tag(0)
                        
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(dataProvider.languages) { section in
                                    Button {
                                        UserDefaults.standard.set(section.id, forKey: "languageCode")
                                        
                                        for (index, language) in dataProvider.languages.enumerated() {
                                            dataProvider.languages[index].isSelected = language.id == section.id
                                        }
                                        dataProvider.loadVideos()
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            tabSelection = TabMenu.videos.rawValue
                                        }
                                    } label: {
                                        LanguageItemView(language: section)
                                        
                                    }
                                    .frame(width: 500)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    
                                }
                            }
                        }
                        .onAppear(perform: {
                            dataProvider.loadLanguages()
                        })
                        .tabItem {
                            HStack {
                                Image(systemName: "gearshape")
                                Text(NSLocalizedString("languages", comment: ""))
                            }
                        }.tag(1)
                    }
                    
                }
                .onAppear {
                    dataProvider.loadVideos()
                }
                
                .onReceive(imageLoader.didChange) { data in
                    self.image = data
                }
                .background(
                    LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.1), .purple.opacity(0.1), .yellow.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                )
                .background(.thickMaterial)
            }
    }
}
