//
//  HypeController.swift
//  Hype
//
//  Created by Jordan Lamb on 10/14/19.
//  Copyright © 2019 Squanto Inc. All rights reserved.
//

import Foundation
import CloudKit

class HypeController {
    
    // Shared Instance
    static let shared = HypeController()
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // SOT
    var hypes: [Hype] = []
    
    
    // Crud
    
    /**
     Saves a Hype object to the PublicDatabase
     
     - Parameters:
         - text: String value for the Hypes's body.
         - completion: Escaping completion block for the method.
         - success: Boolean value returned in the completion block indicating success or failure on saving the CKRecord to CloudKit and reinitialzing as the Object.
     */
    func saveHype(with text: String, completion: @escaping (_ success: Bool) -> Void) {
        // Declares newHype, assignes it to an initialized Hype object, taking the text parameter and passing it in for the body.
        let newHype = Hype(body: text)
        // Initializes a new CKRecord with a Hype using our convenience init on our CKRecord extension.
        let hypeRecord = CKRecord(hype: newHype)
        // Access the save method on our database to save the hypeRecord, completes with an optional record and error.
        publicDB.save(hypeRecord) { (record, error) in
            // Handling the error. If there is one print the description and complete with false.
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            
            // Unwrap the record that was saved, then turning into our Model object using our failable convenience initializer.
            guard let record = record,
                let savedHype = Hype(ckRecord: record)
                else { completion(false) ; return }
            
            // Appending the savedHype to our SOT, completing true
            self.hypes.append(savedHype)
            print("Hype saved successfully")
            completion(true)
        }
    }
    
    // FETCH
    func fetchAllHypes(completion: @escaping (_ success: Bool) -> Void) {
        
        // Step 3 - Creating a predicate to pass into the CKQuery
        let predicate = NSPredicate(value: true)
        // Step 2 - Creating a query constant and assigning it to a CKQuery, initalized with our recordTypeKey and it requires a predicate.
        let query = CKQuery(recordType: HypeStrings.recordTypeKey, predicate: predicate)
        // Step 1 - Access the perform method on the publicDB, which requires a CKQuery
        publicDB.perform(query, inZoneWith: nil) { (foundRecords, error) in
            // Hnadling the error. If there is one, pring the description and complete with false.
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            
            // Check to make sure we retrived records, if not complete false and return
            guard let records = foundRecords else {
                completion(false) ; return }
            
            // Creating an array of hypes from the records array, compactMaping through it to return the non-nil values.
            let hypes = records.compactMap( { Hype(ckRecord: $0) } )
            
            // Assign our SOT and complete with true.
            self.hypes = hypes
            print("Fetched hypes successfully")
            completion(true)
        }
    }
}
