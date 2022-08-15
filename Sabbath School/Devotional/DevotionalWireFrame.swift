//
//  DevotionalWireFrame.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 15/08/22.
//  Copyright © 2022 Adventech. All rights reserved.
//

import AsyncDisplayKit

class DevotionalWireFrame: DevotionalWireFrameProtocol {
    static func createDevotionalModuleNav() -> ASNavigationController {
        let controller = DevotionalViewController()
        return ASNavigationController(rootViewController: controller)
    }
}
