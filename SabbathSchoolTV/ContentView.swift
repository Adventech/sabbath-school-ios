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

struct ContentView: View {
    
    @ObservedObject var dataProvider = DataProvider()
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    @State var image: UIImage = UIImage()
    
//    @ObservedObject var languageDataProvider = LanguageDataProvider()
    
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
                    TabView {
                        
                        VStack(spacing: 0) {
//                            HStack(spacing: 0) {
//                                Spacer()
//                                Image("ssa-logo").resizable().aspectRatio(contentMode: .fit).clipped().frame(width: 100)
//                                
//                                Text("Sabbath School")
//                                    .font(.title3)
//                                    .bold()
//                            }
                            
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
//                                Text("All Videos")
                                Text(NSLocalizedString("videos", comment: ""))
                            }
                        }
                        
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(dataProvider.languages) { section in
    //                                VideoListView(section: section, didTapLink: { backgroundImage in
    //                                    imageLoader.loadImage(urlString: backgroundImage.thumbnail)
    //
    //                                })
    //                                Text(section.language)
                                    Button {
                                        UserDefaults.standard.set(section.id, forKey: "languageCode")
                                        
                                        for (index, language) in dataProvider.languages.enumerated() {
                                            dataProvider.languages[index].isSelected = language.id == section.id
                                        }
//                                        dataProvider.languages.forEach { inout language in
//                                            language.isSelected = language.id == section.id
//                                        }
                                        
                                        
                                        dataProvider.teste()
                                    } label: {
                                        LanguageItemView(language: section)
                                            
                                    }
                                    .frame(width: 500)//), height: 100)
                                    
//                                    .frame(minWidth: 400, idealWidth: 450, maxWidth: 456)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    
                                }
                            }
                        }
//                        Text("Configurações")
                            .onAppear(perform: {
                                debugPrint("l22 linguagem apareceu")
                                dataProvider.loadLanguages()
                            })
//                        VStack
                            .tabItem {
                                HStack {
//                                    Image("icon-navbar-language")//.resizable().frame(width: 40, height: 40, alignment: .center)
                                    Image(systemName: "gearshape")
//                                    Text("Language")
                                    Text(NSLocalizedString("languages", comment: ""))
                                }
                            }
                        
                        
                        
                        
                    }
                    
                }
                .onAppear {
                    dataProvider.teste()
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
