//
//  ReaderView.swift
//  Sabbath School
//
//  Created by Vitaliy Lim on 2017-06-04.
//  Copyright © 2017 Adventech. All rights reserved.
//

import UIKit

protocol ReaderViewDelegateProtocol {
    func showContextMenu()
}

class ReaderView: UIWebView {
    var readerViewDelegate: ReaderViewDelegateProtocol?
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            readerViewDelegate?.showContextMenu()
        }
        return false
    }
}
