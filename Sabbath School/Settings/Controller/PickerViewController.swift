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

protocol PickerViewControllerDelegate: class {
    func pickerView(_ pickerView: PickerViewController, didChangedToDate date: Date)
}

final class PickerViewController: UIViewController {
    weak var delegate: PickerViewControllerDelegate?
    var datePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        datePicker.frame = CGRect(origin: CGPoint.zero, size: preferredContentSize)
        datePicker.addTarget(self, action: #selector(PickerViewController.datePickerChanged(_:)), for: .valueChanged)
        view.addSubview(datePicker)
    }

    // MARK: Functions

    @objc func datePickerChanged(_ sender: UIDatePicker) {
        delegate?.pickerView(self, didChangedToDate: sender.date)
    }
}
