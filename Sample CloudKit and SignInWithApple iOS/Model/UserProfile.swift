//
//  UserProfile.swift
//  Sample CloudKit and SignInWithApple iOS
//
//  Created by Rizal Hilman on 21/11/22.
//

import Foundation
import CloudKit

struct UserProfile: Hashable {
    var userIdentifier: String
    var appleIDEmail: String
    var givenName: String
    var familyName: String
}

enum UserProfileRecordKeys: String {
    case type = "UserProfile"
    case userIdentifier
    case appleIDEmail
    case givenName
    case familyName
}

extension UserProfile {
    var record: CKRecord {
        let record = CKRecord(recordType: UserProfileRecordKeys.type.rawValue, recordID: CKRecord.ID(recordName: userIdentifier))
        record[UserProfileRecordKeys.userIdentifier.rawValue] = userIdentifier
        record[UserProfileRecordKeys.appleIDEmail.rawValue] = appleIDEmail
        record[UserProfileRecordKeys.givenName.rawValue] = givenName
        record[UserProfileRecordKeys.familyName.rawValue] = familyName
        
        return record
    }
}


