//
//  NearbyPlaceDetail.swift
//  NearbyPlaces
//
//  Created by Payal Gupta on 10/18/16.
//  Copyright © 2016 Infoedge Pvt. Ltd. All rights reserved.
//

import UIKit

public let kGoogleAPIKey : String = "AIzaSyA-80bYgdT6jJdi-K7SQQ4gqkHms3t4jP4"

open class NearbyPlaceEntity : NSObject, NSCoding
{
    //MARK: Internal Properties
    open let name : String
    open let address : String
    open let placeID : String
    open var icon : String?
    
    //MARK: Initializer
    public init?(jsonDictionary : [String : AnyObject])
    {
        guard let name =  jsonDictionary["name"] as? String, let placeID = jsonDictionary["place_id"] as? String, let address =  jsonDictionary["vicinity"] as? String else
        {
            return nil
        }
        self.name = name
        self.placeID = placeID
        self.address = address
        self.icon = jsonDictionary["icon"] as? String
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.address = aDecoder.decodeObject(forKey: "address") as! String
        self.placeID = aDecoder.decodeObject(forKey: "placeID") as! String
        self.icon = aDecoder.decodeObject(forKey: "icon") as? String
    }
    
    public func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.address, forKey: "address")
        aCoder.encode(self.placeID, forKey: "placeID")
        aCoder.encode(self.icon, forKey: "icon")
    }
}
