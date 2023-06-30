//
//  DevotionalFeedGroupListViewV4.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 24/06/23.
//  Copyright © 2023 Adventech. All rights reserved.
//

import SwiftUI

struct DevotionalFeedGroupListViewV4: View {
    
    let resourceGroup: ResourceGroup
    
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
                DevotionalFeedListViewV4(resource: resource)
            }
        }
    }
}

struct DevotionalFeedGroupListViewV4_Previews: PreviewProvider {
    static var previews: some View {
        DevotionalFeedGroupListViewV4(resourceGroup: BlockMockData.generateResourceGroup())
    }
}
