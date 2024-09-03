//
//  ViewExtensions.swift
//  WidgetExtension
//
//  Created by Emerson Carpes on 11/02/24.
//  Copyright © 2024 Adventech. All rights reserved.
//

import SwiftUI

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}
