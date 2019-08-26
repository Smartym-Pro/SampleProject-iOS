//
//  Date+Extensions.swift
//  FirebaseSample
//
//  Created by Pavel H on 7/12/19.
//  Copyright © 2019 smartum.pro. All rights reserved.
//

import Foundation

extension Date {
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
