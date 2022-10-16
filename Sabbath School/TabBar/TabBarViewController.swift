/*
 * Copyright (c) 2022 Adventech <info@adventech.io>
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

class TabBarViewController: ASTabBarController {
    func tabBarControllersFor(quarterlyIndex: String? = nil,
                              lessonIndex: String? = nil,
                              readIndex: Int? = nil,
                              initiateOpen: Bool = false) -> [UIViewController] {
        
        let sabbathSchool = QuarterlyWireFrame.createQuarterlyModule()
        let personalMinistries = DevotionalWireFrame.createDevotionalModuleNav(devotionalType: .pm)
        let moreStudy = DevotionalWireFrame.createDevotionalModuleNav(devotionalType: .study)
        
        if let quarterlyIndex = quarterlyIndex {
            let lessonController = LessonWireFrame.createLessonModule(quarterlyIndex: quarterlyIndex, initiateOpenToday: initiateOpen)
            sabbathSchool.pushViewController(lessonController, animated: false)
            
            if let lessonIndex = lessonIndex {
                let readController = ReadWireFrame.createReadModule(lessonIndex: lessonIndex, readIndex: readIndex)
                sabbathSchool.pushViewController(readController, animated: false)
            }
            
        }
        
        sabbathSchool.tabBarItem.image = R.image.iconNavbarSs()
        sabbathSchool.tabBarItem.imageInsets = UIEdgeInsets(top: 9, left: 0, bottom: -9, right: 0)
        
        personalMinistries.tabBarItem.image = R.image.iconNavbarPm()
        personalMinistries.tabBarItem.imageInsets = UIEdgeInsets(top: 9, left: 0, bottom: -9, right: 0)
        
        moreStudy.tabBarItem.image = R.image.iconNavbarDevo()
        moreStudy.tabBarItem.imageInsets = UIEdgeInsets(top: 9, left: 0, bottom: -9, right: 0)
        
        return [sabbathSchool, personalMinistries, moreStudy]
    }
}
