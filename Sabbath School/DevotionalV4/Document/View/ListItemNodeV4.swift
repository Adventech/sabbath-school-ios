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

struct ListItemNodeV4: View {
    
    let block: Block.ListItem
    let index: Int
    var contextMenuAction: ((ContextMenuAction) -> Void)?
    
    var body: some View {
        HStack {
            TextNodeV4(font: R.font.latoMedium(size: 18)!, bibleVerses: [], text: "\(index). " + block.markdown, contextMenuAction: contextMenuAction)
        }
    }
}

struct ListItemNodeV4_Previews: PreviewProvider {
    static var previews: some View {
        let block = Block.ListItem(type: "list-item", markdown: "Daily personal prayer")
        
        ListItemNodeV4(block: block, index: 1, contextMenuAction: { _ in })
    }
}
