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

struct DevotionalFeedListViewV4: View {
    
    let resource: Resource
    
    var body: some View {
        VStack {
            Text(AppStyle.Devo.Text.resourceListTitle(string: resource.title))
                .frame(maxWidth: .infinity ,alignment: .leading)
                .padding(EdgeInsets(top: 8, leading: 15, bottom: 0, trailing: 15))
            
            Text(AppStyle.Devo.Text.resourceListSubtitle(string: resource.subtitle ?? ""))
                .frame(maxWidth: .infinity ,alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 15, bottom: 8, trailing: 15))
            Divider().background(Color( .baseGray1 | .baseGray4)).frame(height: 0)
        }
    }
}

struct DevotionalFeedListViewNew_Previews: PreviewProvider {
    static var previews: some View {
        DevotionalFeedListViewV4(resource: BlockMockData.generateTileResource())
    }
}
