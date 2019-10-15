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
    
    // Update
    func updateHype(hype: Hype, completion: @escaping (_ success: Bool) -> Void) {
        // Step 3 - Defining the recordToUpdate and and passing it into our operation
        let recordToUpdate = CKRecord(hype: hype)
        // Step 2 - Defining the operation, and passing in the array of records to save.
        let operation = CKModifyRecordsOperation(recordsToSave: [recordToUpdate], recordIDsToDelete: nil)
        // Step 4 - Adjusting the properties for the operation
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { records, _, error in
            // Handle the error
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            // Make sure our record that was updated matches the record we passed in, complete true if it does.
            guard recordToUpdate == records?.first else {
                print("Unexpected record was updated")
                completion(false)
                return
            }
            
            print("Updated \(recordToUpdate.recordID) successfully in CloudKit")
            completion(true)
        }
        // Step 1 - Calling the add method on the publicDB that requires an operation.
        publicDB.add(operation)
    }
    
    
    // Delete
    func deleteHype(hype: Hype, completion: @escaping (_ success: Bool) -> Void) {
        // Step 2 - Defining the operation, and passing in the array of recordIDs to delete.
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [hype.ckRecordID])
        // Step 3 - Set properties of our operation
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { _, recordIDs, error in
            // Handling errors and complete with false.
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            // Comparing the hype.ckRecordID that we wanted to delete to the recordID that was deleted. If they match we complete true.
            guard hype.ckRecordID == recordIDs?.first else {
                completion(false)
                print("Unexpected recordID was deleted")
                return }
            print("Successfully delete Hype")
            completion(true)
        }
        // Step 1 - Calling the add method on the publicDB that requires an operation.
        publicDB.add(operation)
    }
    
    func slowDeleteHype(hype: Hype, completion: @escaping (_ success: Bool) -> Void) {
        // Calling delete on the publicDB, passing in the recordID that we want to delete.
        publicDB.delete(withRecordID: hype.ckRecordID) { (recordID, error) in
            // Handle the error and complete with false.
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            
            // Check to make sure the recordID was deleted, then it was, remove it from the local source of truth.
            if recordID != nil {
                guard let index = self.hypes.firstIndex(of: hype)
                    else { completion(false) ; return }
                self.hypes.remove(at: index)
            }
        }
    }
    
    func subscribeForRemoteNotifications(completion: @escaping (_ error: Error?) ->Void) {
        //  Step 3 - Declaring the predicate with a true value for our subscription
        let preditcate = NSPredicate(value: true)
        // Step 2 - Declaring a subscription, giving it a type and a predicate
        let subscription = CKQuerySubscription(recordType: HypeStrings.recordTypeKey, predicate: preditcate, options: .firesOnRecordCreation)
        // Step 4 - Tell our notification what it should look like
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "CHOO CHOO"
        notificationInfo.alertBody = "Can't stop the hype train!!"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        // Step 5 - Set the subscription notificationInfo to the notificatoinInfo from step 4
        subscription.notificationInfo = notificationInfo
        // Step 1 - Calling save method on our publicDB and passing in a subscription
        publicDB.save(subscription) { (_, error) in
            // Handle error
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(error)
            }
            completion(nil)
        }
    }
    
}
