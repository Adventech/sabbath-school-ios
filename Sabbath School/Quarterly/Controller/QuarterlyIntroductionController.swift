/*
 * Copyright (c) 2017 Adventech <info@adventech.io>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import AsyncDisplayKit
import SafariServices
import UIKit

class QuarterlyIntroductionController: ASDKViewController<ASDisplayNode> {
    let quarterly: Quarterly
    var table = ASTableNode()
    let collectionViewLayout = UICollectionViewFlowLayout()
    
    var blocks: [Block] = []

    init(quarterly: Quarterly) {
        self.quarterly = quarterly
        super.init(node: table)
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = AppStyle.Base.Color.background
        title = quarterly.title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCloseButton()
        self.table.view.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        let json = """
[
  {
    "type": "paragraph",
    "markdown": "boo",
    "data": {
      "a": "b"
    }
  },
  {
    "type": "paragraph",
    "markdown": "HELLO WORLD"
  },
  {
    "type": "paragraph",
    "markdown": "HWPO YO!"
  },
  {
    "type": "reference",
    "target": "es/pm/discipleship-handbook",
    "title": "Discipleship Handbook",
    "subtitle": null,
    "scope": "resource"
  },
  {
    "type": "reference",
    "target": "es/pm/discipleship-handbook/content/00-introduction.md",
    "title": "Introduction",
    "subtitle": "Discipleship Handbook",
    "scope": "document"
  },
  {
    "type": "audio",
    "src": "es/pm/discipleship-handbook/01",
    "title": "test2",
    "subtitle": null
  },
  {
    "type": "video",
    "src": "es/pm/discipleship-handbook/01",
    "title": "test",
    "subtitle": null
  },
  {
    "type": "collapse",
    "caption": "testing",
    "items": [
      {
        "type": "paragraph",
        "markdown": "Hello, world!"
      },
      {
        "type": "paragraph",
        "markdown": "_test_"
      },
      {
        "type": "reference",
        "target": "es/pm/discipleship-handbook",
        "title": "Discipleship Handbook",
        "subtitle": null,
        "scope": "resource"
      }
    ]
  },
  {
    "type": "question",
    "markdown": "How are you doing?"
  },
  {
    "type": "appeal",
    "markdown": "hello"
  },
  {
    "type": "paragraph",
    "markdown": "test"
  },
  {
    "type": "multiple-choice",
    "items": [
      {
        "type": "list-item",
        "markdown": "hello"
      },
      {
        "type": "list-item",
        "markdown": "hello"
      }
    ],
    "ordered": false,
    "start": 0,
    "answer": 0
  },
  {
    "type": "image",
    "src": "https://picsum.photos/450/300",
    "caption": "Google"
  },
  {
    "type": "blockquote",
    "memoryVerse": true,
    "caption": "Memory verse",
    "items": [
      {
        "type": "paragraph",
        "markdown": "[Rev 13](sspmBible://Rev13)"
      },
      {
        "type": "reference",
        "target": "es/pm/discipleship-handbook",
        "title": "Discipleship Handbook",
        "subtitle": null,
        "scope": "resource"
      },
      {
        "type": "paragraph",
        "markdown": "[Rev 22](sspmBible://Rev22)"
      }
    ]
  },
  {
    "type": "blockquote",
    "caption": "Yes",
    "citation": true,
    "items": [
      {
        "type": "paragraph",
        "markdown": "[Gen 22](sspmBible://Gen22)"
      }
    ]
  },
  {
    "type": "question",
    "markdown": "How are you doing?"
  },
]
""".data(using: .utf8)!
        do {
            self.blocks = try JSONDecoder().decode(Array<Block>.self, from: json)
        } catch let error {
            print("SSDEBUG", error)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self.table, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = AppStyle.Base.Color.navigationTint
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            self.table.contentInset.bottom = 0
        } else {
            var contentInset: UIEdgeInsets = self.table.contentInset
            contentInset.bottom = keyboardViewEndFrame.size.height
            contentInset.bottom = contentInset.bottom - view.safeAreaInsets.bottom
            self.table.contentInset = contentInset
        }
    }
}

extension QuarterlyIntroductionController: ASTableDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
}

extension QuarterlyIntroductionController: ASTableDataSource {
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let cellNodeBlock: () -> ASCellNode = {
            return QuarterlyIntroductionView(blocks: self.blocks)
        }

        return cellNodeBlock
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
