//
//  LocationManager.swift
//  NearbyPlaces
//
//  Created by Payal Gupta on 10/17/16.
//  Copyright © 2016 Infoedge Pvt. Ltd. All rights reserved.
//

import UIKit
import CoreLocation

public class LocationManager: NSObject
{
    public static let sharedManager = LocationManager()
    
    public lazy var locationManager:CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self;
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.distanceFilter = 500;
        return manager
    }()
    
    public func currentLocation() -> CLLocation?
    {
        self.startUpdatingLocation()
        return self.locationManager.location
    }
    
    public func stopUpdatingLocation()
    {
        self.locationManager.stopUpdatingLocation()
    }
    
    public func startUpdatingLocation()
    {
        self.locationManager.startUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate Methods
extension LocationManager : CLLocationManagerDelegate
{
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted
        {
            //Show Alert
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        //Show Alert
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        //Show Alert
        self.stopUpdatingLocation()
    }
}
