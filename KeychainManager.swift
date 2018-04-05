//
//  KeychainManager.swift
//  Created by Yebeltal Asseged on 10/11/17.
//

// save username / emailaddress, password

import Foundation.NSCoder

internal class KeychainManager : NSObject {
    
    private let keychainDictionary: (String) -> [String : Any] = { key in
        
        let identifier : Data? = key.data(using: String.Encoding.utf8)
        
        let secClass = kSecClass as String
        let secAttrService = kSecAttrService as String
        let secAttrAccessible = kSecAttrAccessible as String
        let secAttrGeneric = kSecAttrGeneric as String
        let secAttrAccount = kSecAttrAccount as String
        
        var _keychainDictionary : [String : Any] = [secClass : kSecSharedPassword]
        _keychainDictionary[secAttrService] = Bundle.main.bundleIdentifier
        _keychainDictionary[secAttrAccessible] = kSecAttrAccessibleWhenUnlocked
        _keychainDictionary[secAttrGeneric] = identifier
        _keychainDictionary[secAttrAccount] = identifier
        
        return _keychainDictionary
        
    }
    
    internal func save(_ value: String, forKey key: String) -> Bool{
        
        let valueUtf = value.data(using: .utf8)
        
        let secValueData = kSecValueData as String
        
        // dictionary
        var dictionary = keychainDictionary(key)
        dictionary[secValueData] = valueUtf
        
        // write, if duplicate, update
        switch SecItemAdd(dictionary as CFDictionary, nil) as OSStatus {
        case errSecSuccess :
            return true
        case errSecDuplicateItem :
            let secDictionary =  [secValueData : valueUtf]
            return SecItemUpdate(dictionary as CFDictionary, secDictionary as CFDictionary) == errSecSuccess
        default :
            return false
        }
    }
    
    
    internal func retrive(forKey key: String) -> String?{
        
        let secMatchLimit = kSecMatchLimit as String
        let secReturnData = kSecReturnData as String
        
        var dictionary = keychainDictionary(key)
        dictionary[secMatchLimit] = kSecMatchLimitOne
        dictionary[secReturnData] = kCFBooleanTrue
        
        var result: AnyObject?
        let status = SecItemCopyMatching(dictionary as CFDictionary, &result)
        
        guard let _result = result as? Data else {
            return nil
        }
        
        return status == noErr ? String(data: _result, encoding: String.Encoding.utf8) as String?: nil
    }
    
    internal func delete(_ key : String) -> Bool {

        let dictionary = keychainDictionary(key)
        
        return SecItemDelete(dictionary as CFDictionary) as OSStatus  == errSecSuccess
    }
}
