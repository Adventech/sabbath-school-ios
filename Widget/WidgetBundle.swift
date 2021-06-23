//
//  WidgetBundle.swift
//  WidgetExtension
//
//  Created by Vitaliy Lim on 2021-06-20.
//  Copyright © 2021 Adventech. All rights reserved.
//

import SwiftUI
import WidgetKit

@main
struct SabbathSchoolWidgets: WidgetBundle {
   var body: some Widget {
       TodayWidget()
       FeaturedTodayWidget()
       LessonInfoWidget()
   }
}
