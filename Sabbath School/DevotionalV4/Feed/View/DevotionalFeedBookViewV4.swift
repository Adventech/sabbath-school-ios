//
//  DevotionalFeedBookViewV4.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 24/06/23.
//  Copyright © 2023 Adventech. All rights reserved.
//

import SwiftUI

struct DevotionalFeedBookViewV4: View {
    
    let resource: Resource
    let inline: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            AsyncImage(url: resource.cover) { image in
                image.image?.resizable()
                    .scaledToFill()
                    .frame(maxWidth: 90, maxHeight: 90 * 1.5)
                    .cornerRadius(4)
                    .shadow(color: Color(UIColor(white: 0, alpha: 0.6)), radius: 4, x: 0, y: 0)
            }
            VStack(spacing: 8) {
                Text(AppStyle.Devo.Text.resourceListSubtitle(string: resource.subtitle ?? "")).lineLimit(2)
                Text(AppStyle.Devo.Text.resourceListTitle(string: resource.title)).frame(maxWidth: .infinity ,alignment: .leading)
                
            }
        }
        .padding(EdgeInsets(top: 1, leading: inline ? 20 : 0, bottom: 1, trailing: inline ? 20 : 0))
    }
}

struct DevotionalFeedBookViewNew_Previews: PreviewProvider {
    static var previews: some View {
        let resource = BlockMockData.generateResource()
        DevotionalFeedBookViewV4(resource: resource, inline: true)
    }
}
