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

struct DevotionalFeedGroupListViewV4: View {
    
    let resourceGroup: ResourceGroup
    var didTapResource: ((String) -> Void)?
    
    var body: some View {
        VStack {
            Text(AppStyle.Devo.Text.resourceGroupName(string: resourceGroup.title.uppercased()))
                .frame(maxWidth: .infinity ,alignment: .leading)
                .padding(EdgeInsets(top: 15, leading: 15, bottom: 8, trailing: 0))
            AsyncImage(url: resourceGroup.cover) { image in
                image.image?.resizable()
                    .scaledToFit()
            }
            .cornerRadius(4)
            
            ForEach(resourceGroup.resources, id: \.self) { resource in
                DevotionalFeedListViewV4(resource: resource, didTapResource: didTapResource)
            }
        }
    }
}

struct DevotionalFeedGroupListViewV4_Previews: PreviewProvider {
    static var previews: some View {
        DevotionalFeedGroupListViewV4(resourceGroup: BlockMockData.generateResourceGroup())
    }
}
