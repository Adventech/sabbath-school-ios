//
//  DevotionalFeedGroupSmallTileViewV4.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 24/06/23.
//  Copyright © 2023 Adventech. All rights reserved.
//

import SwiftUI

struct DevotionalFeedGroupSmallTileViewV4: View {
    
    let resourceGroup: ResourceGroup
    @State private var selectedView: Int?
    
    var body: some View {
        VStack {
            Text(AppStyle.Devo.Text.resourceGroupName(string: resourceGroup.title.uppercased()))
                .frame(maxWidth: .infinity ,alignment: .leading)
                .padding(EdgeInsets(top: 15, leading: 15, bottom: 8, trailing: 0))

            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(resourceGroup.resources, id: \.self) { resource in
                        DevotionalFeedSmallTileViewV4(resource: resource).frame(width: 300, height: 260)
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
            }
            .scrollIndicators(.hidden)
        }
    }
}

struct DevotionalFeedGroupSmallTileViewV4_Previews: PreviewProvider {
    static var previews: some View {
        DevotionalFeedGroupSmallTileViewV4(resourceGroup: BlockMockData.generateTileResourceGroup())
    }
}
