//
//  CoreDataImporter.swift
//  JournalCoreData
//
//  Created by Andrew R Madsen on 9/10/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataImporter {
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func sync(entries: [EntryRepresentation], completion: @escaping (Error?) -> Void = { _ in }) {
        
        self.context.perform {
     
            let identifiers = entries.compactMap {$0.identifier}

            let entriesArr = self.fetchSingleEntryFromPersistentStore(with: identifiers, in: self.context)
            
            guard let returnEntries = entriesArr else {return}
            
            var entriesDic: [String:Entry] = [:]
            
            for entry in returnEntries {
                guard let indetifier = entry.identifier else {continue}
                entriesDic[indetifier] = entry
            }
            
            for entryRep in entries{
                
                guard let indetifier = entryRep.identifier else {continue}
                
                if let entry = entriesDic[indetifier]{
                    if entry != entryRep {
                        self.update(entry: entry, with: entryRep)
                    }
                    
                } else {
                    _ = Entry(entryRepresentation: entryRep, context: self.context)
                }
            }
        }
        completion(nil)
 
    }
    
    private func update(entry: Entry, with entryRep: EntryRepresentation) {
        entry.title = entryRep.title
        entry.bodyText = entryRep.bodyText
        entry.mood = entryRep.mood
        entry.timestamp = entryRep.timestamp
        entry.identifier = entryRep.identifier
    }
    
    private func fetchSingleEntryFromPersistentStore(with identifier: [String]?, in context: NSManagedObjectContext) -> [Entry]? {
        
        guard let identifier = identifier else { return nil }
        
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifier)
        
        var result: [Entry]? = nil
        do {
            result = try context.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching single entry: \(error)")
        }
        return result
    }
    
    let context: NSManagedObjectContext
}
