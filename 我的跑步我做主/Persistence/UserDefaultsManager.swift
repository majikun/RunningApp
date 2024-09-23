//
//  UserDefaultsManager.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/6/24.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let runRecordsKey = "runRecords"
    
    func saveRunRecords(_ records: [RunRecord]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(records) {
            UserDefaults.standard.set(encoded, forKey: runRecordsKey)
        }
    }
    
    func loadRunRecords() -> [RunRecord] {
        if let data = UserDefaults.standard.data(forKey: runRecordsKey) {
            let decoder = JSONDecoder()
            if let records = try? decoder.decode([RunRecord].self, from: data) {
                return records
            }
        }
        return []
    }
}
