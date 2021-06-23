//
//  NetworkImage.swift
//  WidgetExtension
//
//  Created by Vitaliy Lim on 2021-06-20.
//  Copyright © 2021 Adventech. All rights reserved.
//

import Foundation
import SwiftUI

struct NetworkImage: View {

  public let url: URL?

  var body: some View {
    Group {
     if let url = url, let imageData = try? Data(contentsOf: url),
       let uiImage = UIImage(data: imageData) {

       Image(uiImage: uiImage)
         .resizable()
         .aspectRatio(contentMode: .fit)
      }
      else {
       Image("QuarterlyPlaceholder")
      }
    }
  }

}
