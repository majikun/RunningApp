import SwiftData
import Foundation

@MainActor
class PersistenceManager {
    static let shared = PersistenceManager()
    
    internal var container: ModelContainer?
    
    init() {
        do {
            //try deletePersistentStore()
            self.container = try ModelContainer(for: RunStageResult.self, RunningRecord.self)
        } catch {
            print("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    func deletePersistentStore() throws {
        if let url = getPersistentStoreURL() {
            let fileManager = FileManager.default
            let storeFiles = [url, url.appendingPathExtension("wal"), url.appendingPathExtension("shm")]
            
            for fileURL in storeFiles {
                if fileManager.fileExists(atPath: fileURL.path) {
                    try fileManager.removeItem(at: fileURL)
                    print("Deleted store file at \(fileURL)")
                }
            }
        }
    }
    
    private func getPersistentStoreURL() -> URL? {
        // 获取数据库文件的路径，通常在应用的 Library/Application Support 目录中
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let storeURL = documentsDirectory.appendingPathComponent("default.store")
            return storeURL
        }
        return nil
    }
    
    // MARK: - RunningRecord 的操作
    func saveRunningRecord(_ record: RunningRecord) throws {
        guard let container = container else {
            throw NSError(domain: "PersistenceManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "ModelContainer is not initialized"])
        }
        let id = record.id
        let fetchRequest = FetchDescriptor<RunningRecord>(
            predicate: #Predicate { recordInStore in
                recordInStore.id == id
            }
        )
        
        let existingRecords = try container.mainContext.fetch(fetchRequest)
        
        if let existingRecord = existingRecords.first {
            // 更新现有记录
            existingRecord.totalDistance = record.totalDistance
            existingRecord.totalTime = record.totalTime
            existingRecord.endTime = record.endTime
            existingRecord.coordinates = record.coordinates
        } else {
            // 插入新记录
            container.mainContext.insert(record)
        }
        
        // 保存上下文
        try container.mainContext.save()
    }
    
    func fetchAllRunningRecords() -> [RunningRecord] {
        guard let container = container else { return [] }
        let fetchRequest = FetchDescriptor<RunningRecord>()
        do {
            return try container.mainContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch records: \(error)")
            return []
        }
    }
    
    func deleteRunningRecord(_ record: RunningRecord) throws {
        guard let container = container else {
            throw NSError(domain: "PersistenceManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "ModelContainer is not initialized"])
        }
        container.mainContext.delete(record)
        try container.mainContext.save()
    }
}
