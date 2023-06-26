//
//  DevotionalFeedListViewNew.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 26/06/23.
//  Copyright © 2023 Adventech. All rights reserved.
//

import SwiftUI

struct DevotionalFeedListViewNew: View {
    
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
        DevotionalFeedListViewNew(resource: BlockMockData.generateTileResource())
    }
}
