//
//  DevotionalFeedSmallTileViewV4.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 29/06/23.
//  Copyright © 2023 Adventech. All rights reserved.
//

import SwiftUI

struct DevotionalFeedSmallTileViewV4: View {
    
    let resource: Resource
    
    var body: some View {
        VStack {
            
            AsyncImage(url: resource.tile) { image in
                image.image?.resizable()
            }
            .scaledToFit()
            .cornerRadius(4)
            .overlay {
                VStack(spacing: 8) {
                    Spacer()
                    
                    Text(AppStyle.Devo.Text.resourceListSubtitle(string: resource.subtitle ?? ""))
                        .frame(maxWidth: .infinity ,alignment: .leading)
                    
                    Text(AppStyle.Devo.Text.resourceListTitle(string: resource.title))
                        .frame(maxWidth: .infinity ,alignment: .leading)
                }.padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 15))
                
            }
        }
    }
}

struct DevotionalFeedSmallTileViewV4_Previews: PreviewProvider {
    static var previews: some View {
        DevotionalFeedSmallTileViewV4(resource: BlockMockData.generateBookTileResource())
    }
}
