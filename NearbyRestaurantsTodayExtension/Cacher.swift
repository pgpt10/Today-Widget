//
//  Cacher.swift
//  NearbyRestaurants
//
//  Created by Payal Gupta on 12/22/16.
//  Copyright © 2016 Infoedge Pvt. Ltd. All rights reserved.
//

import Foundation

class Cacher: NSObject
{
    //MARK: - Removing all cachhed file by NNCacher
    static func resetCache()
    {
        do
        {
            _ = try FileManager.default.removeItem(at: URL(fileURLWithPath: self.cacheDirectory().absoluteString))
        }
        catch let error as NSError
        {
            print(error.description)
        }
    }
    
    //MARK: Creating direcory for caching
    // returning URL of caching directory path
    static private func cacheDirectory() -> URL
    {
        var cacheURL = URL(string: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!)
        cacheURL?.appendPathComponent("Caches", isDirectory: true)
        let cacheDirectory: String! = cacheURL?.absoluteString
        var isDir : ObjCBool = false
        if !(FileManager.default.fileExists(atPath: cacheDirectory, isDirectory: &isDir))
        {
            try? FileManager.default.createDirectory(atPath: cacheDirectory, withIntermediateDirectories: false, attributes: nil)
        }
        return cacheURL!
    }
    
    //MARK: Reading data from caching directory
    // returning data for Key(String) from caching directory path
    static func cachedDataforKey(_ key:String) -> Data?
    {
        let url =  self.cacheDirectory().appendingPathComponent(self.cachedFileNameForKey(key))
        let filePath =  url.absoluteString
        let fileURL = URL(fileURLWithPath: filePath)
        if FileManager.default.fileExists(atPath: filePath)
        {
            return  try? Data(contentsOf: fileURL)
        }
        return nil
    }
    
    //MARK: Caching data for key in caching directory
    static func cacheData(_ data: Data, forKey key:String)
    {
        let url =  self.cacheDirectory().appendingPathComponent(self.cachedFileNameForKey(key))
        let fileURL = URL(fileURLWithPath: url.absoluteString)
        do
        {
            _ = try data.write(to: fileURL, options: .atomic)
        }
        catch let error as NSError
        {
            print(error.description)
        }
    }
    
    //MARK: Generating Unique hash for key for file name
    static private func cachedFileNameForKey(_ key: String) -> String
    {
        guard let messageData = key.data(using:String.Encoding.utf8) else
        {
            return key
        }
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        var digestData = Data(count: digestLen)
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", digestData[i])
        }
        return String(hash)
    }
}
