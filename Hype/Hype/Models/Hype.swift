//
//  Hype.swift
//  Hype
//
//  Created by Jordan Lamb on 10/14/19.
//  Copyright © 2019 Squanto Inc. All rights reserved.
//

import Foundation
import CloudKit

// MARK: - Hype Strings
struct HypeStrings {
    static let recordTypeKey = "Hype"
    fileprivate static let bodyKey = "body"
    fileprivate static let timestampKey = "timestamp"
}

class Hype {
    var body: String
    var timestamp: Date
    
    init(body: String, timestamp: Date = Date()) {
        self.body = body
        self.timestamp = timestamp
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
            let timestamp = ckRecord[HypeStrings.timestampKey] as? Date
            else { return nil }
        self.init(body: body, timestamp: timestamp)
    }
}

/// Hype -> Cloud
// MARK: - CDRecord Extension
extension CKRecord {
    /**
     Convenience initializer to create a CKRecord and set the key/vaule pairs based on our Hype model objects.
     - Parameters:
     - hype: Hype Object that we want to set CKRecord key/value pairs for
     */
    convenience init(hype: Hype) {
        // Initalizes a CKRecord
        self.init(recordType: HypeStrings.recordTypeKey)
        self.setValuesForKeys([
            HypeStrings.bodyKey : hype.body,
            HypeStrings.timestampKey : hype.timestamp
            ])
    }
}
