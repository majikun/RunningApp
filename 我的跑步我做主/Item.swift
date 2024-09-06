//
//  Item.swift
//  我的跑步我做主
//
//  Created by 马计坤 on 9/6/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
