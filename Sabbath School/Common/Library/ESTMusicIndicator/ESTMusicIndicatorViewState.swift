//
//  ESTMusicIndicatorView.swift
//  ESTMusicIndicator
//
//  Created by Aufree on 12/6/15.
//  Copyright © 2015 The EST Group. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

/**
 Values for the [state]([ESTMusicIndicatorView state]) property.
 */
public enum ESTMusicIndicatorViewState: Int {
     /**
     Stopped state of an indicator view.
     In this state, if an indicator's [hidesWhenStopped]([ESTMusicIndicatorView hidesWhenStopped]) is `YES`, the indicator becomes hidden.
     Or if an indicator's [hidesWhenStopped]([ESTMusicIndicatorView hidesWhenStopped]) is `NO`, the indicator shows idle bars.
     */
    case stopped
    
    /**
     Playing state of an indicator view.
     In this state, an indicator shows oscillatory animated bars.
     */
    case playing
    
    /**
     Paused state of an indicator view.
     In this state, an indicator shows idle bars.
     */
    case paused
}
