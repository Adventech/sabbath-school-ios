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

struct CollapseNodeV4: View {
    
    let block: Block.Collapse
    var didTapLink: (([BibleVerses], String) -> Void)?
    var didClickReference: ((Block.ReferenceScope, String) -> Void)?
    var contextMenuAction: ((ContextMenuAction) -> Void)
    
    @State private var isCollapsed = false
    
    var body: some View {
        VStack(spacing: 0) {
            DevotionalResourceSectionHeaderViewV4(colapsedSection: false, sectionTitle: block.caption, didTap: {
                isCollapsed = !isCollapsed
            })
            
            if !isCollapsed {
                ForEach(block.items, id: \.self) { block in
                    BlockWrapperNodeV4(block: block, didTapLink: didTapLink, didClickReference: didClickReference, contextMenuAction: contextMenuAction)
                }
            }
        }
        .padding(EdgeInsets())
    }
}

struct CollapseNodeV4_Previews: PreviewProvider {
    static var previews: some View {
        let block = Block.Collapse(type: "colapse", caption: "", items: [])
        
        CollapseNodeV4(block: block, contextMenuAction: { _ in })
    }
}
