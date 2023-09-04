//
//  CopyrightsView.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 04/09/23.
//  Copyright © 2023 Adventech. All rights reserved.
//

import SwiftUI

struct CopyrightsView: View {
    
    let credits: [Credits]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(credits) { credit in
                VStack(spacing: 2) {
                    Group {
                        Text(AppStyle.Lesson.Text.creditsName(string: credit.name))
                        Text(AppStyle.Lesson.Text.creditsValue(string: credit.value))
                    }
                    .frame(maxWidth: .infinity ,alignment: .leading)
                }
            }
        }
        .padding(.all, 16)
        .background(
            Color(uiColor: AppStyle.Lesson.Color.backgroundFooter)
        )
        
        
    }
}

struct CopyrightsView_Previews: PreviewProvider {
    static var previews: some View {
        CopyrightsView(credits: [])
    }
}
