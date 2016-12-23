//
//  NearbyPlaceDetail.swift
//  NearbyRestaurants
//
//  Created by Payal Gupta on 12/22/16.
//  Copyright © 2016 Infoedge Pvt. Ltd. All rights reserved.
//

import Foundation
import NearbyPlaces
import CoreLocation

public class NearbyPlaceDetail : NearbyPlaceEntity
{
    //MARK: Internal Properties
    public var completeAddress : String?
    public var phoneNumber : String?
    public var openNow : Bool
    public var permanentlyClosed : Bool
    public var weekDayText : [String]?
    public var photosIDs : [String]?
    public var googlePageURL : String?
    public var websiteURL : String?
    public var rating : Double?
    
    //MARK: Initializer
    override init?(jsonDictionary : [String : AnyObject])
    {
        self.completeAddress = jsonDictionary["formatted_address"] as? String
        self.phoneNumber = jsonDictionary["formatted_phone_number"] as? String
        if let openingHours = jsonDictionary["opening_hours"] as? [String : AnyObject]
        {
            if let openNow = openingHours["open_now"] as? Bool
            {
                self.openNow = openNow
            }
            else
            {
                self.openNow = false
            }
            self.weekDayText = openingHours["weekday_text"] as? [String]
        }
        else
        {
            self.openNow = false
        }
        self.permanentlyClosed = (jsonDictionary["permanently_closed"] as? Bool) ?? false
        if let photosArray = jsonDictionary["photos"] as? [[String : AnyObject]], photosArray.count > 0
        {
            self.photosIDs = [String]()
            for photo in photosArray
            {
                self.photosIDs?.addObject(photo["photo_reference"] as? String)
            }
        }
        self.googlePageURL = jsonDictionary["url"] as? String
        self.websiteURL = jsonDictionary["website"] as? String
        self.rating = jsonDictionary["rating"] as? Double
        super.init(jsonDictionary: jsonDictionary)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Type Methods
    /**
     Google Nearby Places API hit
     
     - parameter coordinate:        property coordinate for which we need to find nearby places
     - parameter radius:            radius around property within which to find nearby places
     - parameter amenityType:       type of nearby place - railway, atm, airport etc.
     - parameter completionHandler: handler after receiving response
     */
    public static func fetchNearByGooglePlacesForCoordinate(_ coordinate : CLLocationCoordinate2D, inRadius radius : Int, forAmenityType amenityType : String, withCompletionHandler completionHandler : ((Any?,NSError?)->Void)?)
    {
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&types=\(amenityType)&sensor=false&key=\(kGoogleAPIKey)"
        
        let task = URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) in
            
            if error != nil
            {
                DispatchQueue.main.async(execute: {
                    if let handler = completionHandler
                    {
                        handler(nil, error as NSError?)
                    }
                })
            }
            else
            {
                if let data = data
                {
                    do
                    {
                        if let responseObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : AnyObject], let resultsArray = responseObject["results"] as? [[String : AnyObject]] , resultsArray.count > 0
                        {
                            var nearbyPlacesArray = [NearbyPlaceEntity]()
                            for dict in resultsArray
                            {
                                nearbyPlacesArray.addObject(NearbyPlaceEntity(jsonDictionary: dict))
                            }
                            if nearbyPlacesArray.count > 0
                            {
                                DispatchQueue.main.async(execute: {
                                    if let handler = completionHandler
                                    {
                                        handler(nearbyPlacesArray, nil)
                                    }
                                })
                            }
                            else
                            {
                                DispatchQueue.main.async(execute: {
                                    if let handler = completionHandler
                                    {
                                        handler(nil, nil)
                                    }
                                })
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async(execute: {
                                if let handler = completionHandler
                                {
                                    handler(nil, nil)
                                }
                            })
                        }
                    }
                    catch
                    {
                        
                    }
                }
                else
                {
                    DispatchQueue.main.async(execute: {
                        if let handler = completionHandler
                        {
                            handler(nil, nil)
                        }
                    })
                }
            }
        })
        task.resume()
    }

    /**
     Google Place Detail API hit
     
     - parameter placeID:           ID of the place for which to fetch details
     - parameter nearbyPlaceObject: NearbyPlaceDetail type object
     - parameter completionHandler: handler after receiving response
     */
    public static func fetchNearByPlaceDetailForPlaceID(_ placeID : String,  withCompletionHandler completionHandler : ((Any?,NSError?)->Void)?)
    {
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeID)&key=\(kGoogleAPIKey)"
        
        let task = URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) in
            
            if error != nil
            {
                DispatchQueue.main.async(execute: {
                    if let handler = completionHandler
                    {
                        handler(nil, error as NSError?)
                    }
                })
            }
            else
            {
                if let data = data
                {
                    do
                    {
                        if let responseObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : AnyObject], let resultDict = responseObject["result"] as? [String : AnyObject]
                        {
                            let nearbyPlaceDetailObject = NearbyPlaceDetail(jsonDictionary: resultDict)
                            if nearbyPlaceDetailObject != nil
                            {
                                DispatchQueue.main.async(execute: {
                                    if let handler = completionHandler
                                    {
                                        handler(nearbyPlaceDetailObject, nil)
                                    }
                                })
                            }
                            else
                            {
                                DispatchQueue.main.async(execute: {
                                    if let handler = completionHandler
                                    {
                                        handler(nil, nil)
                                    }
                                })
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async(execute: {
                                if let handler = completionHandler
                                {
                                    handler(nil, nil)
                                }
                            })
                        }
                    }
                    catch
                    {
                        
                    }
                }
                else
                {
                    DispatchQueue.main.async(execute: {
                        if let handler = completionHandler
                        {
                            handler(nil, nil)
                        }
                    })
                }
            }
        })
        task.resume()
    }
}

extension Array
{
    /**
     Method to add elements in Array. We cannot add optionals in an Array. So to avoid "if let" checking while adding optional values in Array, this method can be used.
     If the optional is nil, no element added
     If the optional has some value, it is unwrapped and added
     
     -warning: Can only be used with Optional Values
     
     - parameter value: Optional value to be added
     */
    mutating func addObject(_ value : Element?)
    {
        if let object = value
        {
            self.append(object)
        }
    }
}
