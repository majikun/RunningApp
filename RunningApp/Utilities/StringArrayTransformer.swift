//
//  StringArrayTransformer.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 10/21/24.
//

import Foundation
import CoreData

@objc(StringArrayTransformer)
class StringArrayTransformer: ValueTransformer {
    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let array = value as? [String] else { return nil }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: array, requiringSecureCoding: false)
            return data
        } catch {
            print("Error archiving data: \(error)")
            return nil
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            if let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String] {
                return array
            } else {
                return nil
            }
        } catch {
            print("Error unarchiving data: \(error)")
            return nil
        }
    }
}
