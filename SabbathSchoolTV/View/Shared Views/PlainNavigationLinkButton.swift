//
//  PlainNavigationLinkButton.swift
//  SabbathSchoolTV
//
//  Created by Emerson Carpes on 29/10/23.
//  Copyright © 2023 Adventech. All rights reserved.
//

import SwiftUI

struct PlainNavigationLinkButtonStyle: ButtonStyle {
    let didTapLink: (() -> Void)?
    func makeBody(configuration: Self.Configuration) -> some View {
        PlainNavigationLinkButton(didTapLink: didTapLink, configuration: configuration)
    }
}

struct PlainNavigationLinkButton: View {
    
    let didTapLink: (() -> Void)?
    @Environment(\.isFocused) var focused: Bool
    let configuration: ButtonStyle.Configuration
    
    var body: some View {
        configuration.label
            .scaleEffect(focused ? 1.1 : 1)
            .focusable(true)
            .onChange(of: focused) { newValue in
                if newValue {
                    didTapLink?()
                }
            }
    }
}
