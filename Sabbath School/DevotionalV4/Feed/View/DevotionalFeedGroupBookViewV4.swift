//
//  DevotionalFeedGroupBookViewV4.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 24/06/23.
//  Copyright © 2023 Adventech. All rights reserved.
//

import SwiftUI

struct DevotionalFeedGroupBookViewV4: View {
    
    let resourceGroup: ResourceGroup
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(resourceGroup.resources, id: \.self) { resource in
                    DevotionalFeedBookViewV4(resource: resource, inline: true)
                        .frame(width: 300, height: 260)
                }
            }
            .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
        }
        .scrollIndicators(.hidden)
    }
}

struct DevotionalFeedGroupBookViewV4_Previews: PreviewProvider {
    static var previews: some View {
        DevotionalFeedGroupBookViewV4(resourceGroup: BlockMockData.generateTileResourceGroup())
    }
}
