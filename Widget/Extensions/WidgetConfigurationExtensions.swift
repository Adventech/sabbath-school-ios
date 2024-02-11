//
//  WidgetConfigurationExtensions.swift
//  WidgetExtension
//
//  Created by Emerson Carpes on 11/02/24.
//  Copyright © 2024 Adventech. All rights reserved.
//

import SwiftUI

extension WidgetConfiguration {
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        }
        else {
            return self
        }
    }
}
