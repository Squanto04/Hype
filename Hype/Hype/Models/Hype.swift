//
//  Hype.swift
//  Hype
//
//  Created by Jordan Lamb on 10/14/19.
//  Copyright © 2019 Squanto Inc. All rights reserved.
//

import UIKit
import CloudKit

struct HypeStrings {
    static let recordTypeKey = "Hype"
    fileprivate static let bodyKey = "body"
    fileprivate static let timestampKey = "timestamp"
    fileprivate static let userRefKey = "userReference"
    fileprivate static let photoAssetKey = "photoAsset"
}

class Hype {
    var user: User?
    var body: String
    var timestamp: Date
    let ckRecordID: CKRecord.ID
    let userReference: CKRecord.Reference
    
    var hypePhoto: UIImage? {
        get {
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
        do {
            try photoData?.write(to: fileURL)
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
        return CKAsset(fileURL: fileURL)
    }
    
    init(body: String, timestamp: Date = Date(), ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), userReference: CKRecord.Reference, hypePhoto: UIImage? = nil) {
        self.body = body
        self.timestamp = timestamp
        self.ckRecordID = ckRecordID
        self.userReference = userReference
        self.hypePhoto = hypePhoto
    }
}


/// Hype -> Cloud
// MARK: - CKRecord Extension
extension CKRecord {
    /**
     Convenience initializer to create a CKRecord and set the key/vaule pairs based on our Hype model objects.
     - Parameters:
     - hype: Hype Object that we want to set CKRecord key/value pairs for
     */
    convenience init(hype: Hype) {
        // Initalizes a CKRecord
        self.init(recordType: HypeStrings.recordTypeKey, recordID: hype.ckRecordID)
        self.setValuesForKeys([
            HypeStrings.bodyKey : hype.body,
            HypeStrings.timestampKey : hype.timestamp,
            HypeStrings.userRefKey : hype.userReference
            ])
        
        if let asset = hype.photoAsset {
            self.setValue(asset, forKey: HypeStrings.photoAssetKey)
        }
    }
}

///Cloud -> Hype
// MARK: - Convenience Init Extension
extension Hype {
    /**
     Convenience failable initalizer that finds the key/value pairs inthe passed in CKRecord and initializes a Hype from those
     - Parameters:
     -  ckRecord: CKRecord object should contain the key/value pairs of a hype object store in the Cloud
     */
    convenience init?(ckRecord: CKRecord) {
        // Unwrapping the values
        guard let body = ckRecord[HypeStrings.bodyKey] as? String,
            let timestamp = ckRecord[HypeStrings.timestampKey] as? Date,
            let userReference = ckRecord[HypeStrings.userRefKey] as? CKRecord.Reference
            else { return nil }
        var foundPhoto: UIImage?
        if let photoAsset = ckRecord[HypeStrings.photoAssetKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL)
                foundPhoto = UIImage(data: data)
            } catch {
                print("Count not transform asset to data")
            }
        }
        self.init(body: body, timestamp: timestamp, ckRecordID: ckRecord.recordID, userReference: userReference, hypePhoto: foundPhoto)
    }
}

extension Hype: Equatable {
    static func == (lhs: Hype, rhs: Hype) -> Bool {
        return lhs.ckRecordID == rhs.ckRecordID
    }
}

