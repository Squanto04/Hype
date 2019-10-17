//
//  UserController.swift
//  Hype
//
//  Created by Jordan Lamb on 10/16/19.
//  Copyright © 2019 Squanto Inc. All rights reserved.
//

import UIKit
import CloudKit

class UserController {
    
    // Shared Instance
    static let shared = UserController()
    
    // Source of Truth
    var currentUser: User?
    
    // Class properties
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // MARK: - CRUD
    // Create
    func createUserWith(username: String, profilePhoto: UIImage?, completion: @escaping (_ success: Bool) -> Void) {
        // Fetches and returns a reference to the currently logged in Apple ID
        fetchAppleUserReference { (reference) in
            // Ensure we get the reference back
            guard let reference = reference else { completion(false) ; return }
            // Step 1 - Initialize the user to save
            let newUser = User(username: username, appleUserReference: reference, profilePhoto: profilePhoto)
            // Step 2 - Turn the user into a CKRecord to be saved
            let record = CKRecord(user: newUser)
            // Step 3 - Call the save method on the database and pass in the record
            self.publicDB.save(record) { (record, error) in
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    completion(false)
                    return
                }
                guard let savedRecord = record,
                    let savedUser = User(ckRecord: savedRecord)
                    else { completion(false) ; return }
                self.currentUser = savedUser
                print("Created User: \(savedRecord.recordID.recordName)")
                completion(true)
            }
        }
    }
    
    
    func fetchUserFor(_ hype: Hype, completion: @escaping (User?) -> Void) {
        let userID = hype.userReference.recordID
        let preditcate = NSPredicate(format: "%K == %@", argumentArray: ["recordID", userID])
        let query = CKQuery(recordType: UserStrings.recordTypeKey, predicate: preditcate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
                return
            }
            
            guard let record = records?.first,
                let foundUser = User(ckRecord: record)
                else { completion(nil) ; return }
            print("Found user for Hype")
            completion(foundUser)
        }
    }
    
    //Fetch
    func fetchUser(completion: @escaping (_ success: Bool) -> Void) {
        // Step 4 - Fetching the reference needed for our arguements array in step 3
        fetchAppleUserReference { (reference) in
            // Step 5 - Making sure that we have a reference to pass into our arguements
            guard let reference = reference else { completion(false) ; return }
            // Step 3 - Creating the predicate, using an array of arguments, needed for step 2
            let predicate = NSPredicate(format: "%K == %@", argumentArray: [UserStrings.appleUserRefKey, reference])
            // Step 2 - Declaring the query needed for step 1, which needs a Predicate
            let query = CKQuery(recordType: UserStrings.recordTypeKey, predicate: predicate)
            // Step 1 - Calling perform method on the publicDB, which needs a query
            self.publicDB.perform(query, inZoneWith: nil) { (records, error) in
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    completion(false)
                    return
                }
                
                guard let record = records?.first,
                    let foundUser = User(ckRecord: record)
                    else { completion(false) ; return }
                
                self.currentUser = foundUser
                print("Fetched User: \(record.recordID.recordName) successfully")
                completion(true)
            }
        }
    }
    
    // Fetch User Reference
    private func fetchAppleUserReference(completion: @escaping (_ reference: CKRecord.Reference?) -> Void) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
                return
            }
            
            guard let recordID = recordID else { completion(nil) ; return }
            let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            completion(reference)
        }
    }
}
