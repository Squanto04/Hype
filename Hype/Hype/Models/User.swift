//
//  User.swift
//  Hype
//
//  Created by Jordan Lamb on 10/16/19.
//  Copyright © 2019 Squanto Inc. All rights reserved.
//

import UIKit
import CloudKit

struct UserStrings {
    static let recordTypeKey = "User"
    static let appleUserRefKey = "appleUserReference"
    fileprivate static let usernameKey = "username"
    fileprivate static let bioKey = "bio"
    fileprivate static let photoAssetKey = "photoAsset"
}

class User {
    var username: String
    var bio: String
    
    let ckRecordID: CKRecord.ID
    let  appleUserReference: CKRecord.Reference
    
    var profilePhoto: UIImage? {
        get{
            guard let photoData = self.photoData else { return nil }
            return UIImage(data: photoData)
        } set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    var photoData: Data?
    var photoAsset: CKAsset? {
        let tempDirectory = NSTemporaryDirectory()
        let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
        let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("jpg")
        do{
            try photoData?.write(to: fileURL)
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
        return CKAsset(fileURL: fileURL)
    }
    
    
    init(username: String, bio: String = "", ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), appleUserReference: CKRecord.Reference, profilePhoto: UIImage? = nil) {
        self.username = username
        self.bio = bio
        self.ckRecordID = ckRecordID
        self.appleUserReference = appleUserReference
        self.profilePhoto = profilePhoto
    }
}

/// User -> Cloud
extension CKRecord {
    // Giving ourselves a way to initialize a CKRecord, and pass in a User.
    convenience init(user: User) {
        // Initialzes a CKRecord object, assign its type as our User, and its recordID as the user.ckRecord passed in
        self.init(recordType: UserStrings.recordTypeKey, recordID: user.ckRecordID)
        // Set the values for thekeys from our user object that we passed in
        self.setValuesForKeys([
            UserStrings.usernameKey : user.username,
            UserStrings.bioKey : user.bio,
            UserStrings.appleUserRefKey : user.appleUserReference
            ])
        
        if let asset = user.photoAsset {
            self.setValue(asset, forKey: UserStrings.photoAssetKey)
        }
    }
}

/// Cloud -> User
extension User {
    // Giving ourselves the ability to initalize a User from a CKRecord
    convenience init?(ckRecord: CKRecord) {
        // Unwrap the values at the given keys, make sure they are the type that we want, otherwise we return nil
        guard let username = ckRecord[UserStrings.usernameKey] as? String,
            let bio = ckRecord[UserStrings.bioKey] as? String,
            let reference = ckRecord[UserStrings.appleUserRefKey] as? CKRecord.Reference
            else { return nil }
        var foundPhoto: UIImage?
        if let photoAsset = ckRecord[UserStrings.photoAssetKey]  as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL)
                foundPhoto = UIImage(data: data)
            } catch {
                print("Could not transform asset to data")
            }
        }
        // Call the class init
        self.init(username: username, bio: bio, ckRecordID: ckRecord.recordID, appleUserReference: reference, profilePhoto: foundPhoto)
    }
}
