//
//  DevotionalDocumentControllerV4.swift
//  Sabbath School
//
//  Created by Emerson Carpes on 18/07/23.
//  Copyright © 2023 Adventech. All rights reserved.
//

import UIKit

class DevotionalDocumentControllerV4: UIViewController {

    init(index: String) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .blue
    }
}
