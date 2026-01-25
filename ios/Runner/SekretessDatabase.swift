import Foundation
import SwiftData

// Import model types
// Note: Models.swift must be compiled before this file

/// SwiftData database for storing Signal Protocol data
@available(iOS 17.0, *)
class SekretessDatabase {
    static let shared = SekretessDatabase()
    
    let modelContainer: ModelContainer
    let mainContext: ModelContext
    
    private init() {
        let schema = Schema([
            IdentityKeyPairEntity.self,
            IdentityKeyEntity.self,
            RegistrationIdEntity.self,
            PreKeyRecordEntity.self,
            SignedPreKeyRecordEntity.self,
            KyberPreKeyEntity.self,
            SessionEntity.self,
            SenderKeyEntity.self,
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            mainContext = ModelContext(modelContainer)
            print("SwiftData model container initialized successfully")
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var viewContext: ModelContext {
        return mainContext
    }
    
    func saveContext() {
        do {
            try mainContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    func newBackgroundContext() -> ModelContext {
        return ModelContext(modelContainer)
    }
}
