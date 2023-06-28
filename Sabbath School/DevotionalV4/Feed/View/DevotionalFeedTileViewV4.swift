//
//  DevotionalFeedTileViewV4.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 26/06/23.
//  Copyright © 2023 Adventech. All rights reserved.
//

import SwiftUI

struct DevotionalFeedTileViewV4: View {
    
    let resource: Resource
    
    var body: some View {
        VStack {
            
            AsyncImage(url: resource.tile) { image in
                image.image?.resizable()
            }
            .scaledToFit()
            .cornerRadius(4)
            
            Text(AppStyle.Devo.Text.resourceListSubtitle(string: resource.subtitle ?? ""))
                .frame(maxWidth: .infinity ,alignment: .leading)
            
            Text(AppStyle.Devo.Text.resourceListTitle(string: resource.title))
                .frame(maxWidth: .infinity ,alignment: .leading)
            
            Spacer()
        }
    }
}

struct DevotionalFeedTileViewV4_Previews: PreviewProvider {
    static var previews: some View {
        DevotionalFeedTileViewV4(resource: BlockMockData.generateBookTileResource())
    }
}
