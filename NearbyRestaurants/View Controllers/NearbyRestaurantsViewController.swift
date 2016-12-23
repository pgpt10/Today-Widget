//
//  NearbyRestaurantsViewController.swift
//  NearbyRestaurants
//
//  Created by Payal Gupta on 10/18/16.
//  Copyright © 2016 Infoedge Pvt. Ltd. All rights reserved.
//

import UIKit
import NearbyPlaces
import CoreLocation
import NotificationCenter

class NearbyRestaurantsViewController: UIViewController
{
    //MARK: Private Properties
    fileprivate var nearbyRestaurantsArray = [NearbyPlaceEntity]()
    fileprivate var currentLocation : CLLocation?
    private let kAppGroupName = "group.com.infoedge.NearbyRestaurantsSample"
    private var sharedContainer : UserDefaults?
    fileprivate lazy var totalCountAllowed : Int = {
        switch UIScreen.main.bounds.height
        {
        case 480: return 3
        case 568 : return 4
        case 667 : return 5
        case 736 : return 5
        default : return 3
        }
    }()

    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: View Lifecycle Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        LocationManager.sharedManager.locationManager.delegate = self
        self.sharedContainer = UserDefaults(suiteName: kAppGroupName)
        self.tableView.register(UINib(nibName: "NearbyPlaceTableViewCell", bundle: nil), forCellReuseIdentifier: "nearbyPlace")
        self.tableView.estimatedRowHeight = 104
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        //--------------------------------------------------------------------------//
        ////Uncomment this if you want to hide widget when no data is available to show in the widget////////
//        if self.fetchDataFromSharedContainer() == nil
//        {
//            DispatchQueue.main.async(execute: {
//                NCWidgetController.widgetController().setHasContent(false, forWidgetWithBundleIdentifier: "com.infoedge.NearbyRestaurantsSample.NearbyRestaurantsTodayExtension")
//            })
//        }
        //--------------------------------------------------------------------------//
    }

    //MARK: Private Methods
    /// This Method sends the Google Places API hit and the response is then saved in "self.nearbyRestaurantsArray" and reloads the table view
    fileprivate func loadDataFromServer()
    {
        if let currentLocation = self.currentLocation
        {
            self.activityIndicator.startAnimating()
            NearbyPlaceDetail.fetchNearByGooglePlacesForCoordinate(currentLocation.coordinate, inRadius: 500, forAmenityType: "restaurant") {[weak self] (responseObject, error) in
                self?.activityIndicator.stopAnimating()
                guard let nearbyRestaurantsArray = responseObject as? [NearbyPlaceEntity] else
                {
                    if error != nil
                    {
                        let alert = UIAlertView.init(title: "Alert", message: (error?.localizedDescription)!, delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                    
                    return
                }
                self?.nearbyRestaurantsArray = nearbyRestaurantsArray
                self?.tableView.reloadData()
            }
        }
    }
    
    /// This method fetches the data to be displayed in widget from shared container.
    fileprivate func fetchDataFromSharedContainer() -> [Any]?
    {
        if let sharedContainer = self.sharedContainer
        {
            let dataArray = sharedContainer.array(forKey: "NearbyRestaurantsArray")
            return dataArray
        }
        return nil
    }
    
    /// This method save the selected restaurant info "NearbyPlaceEntity" to the shared container
    ///
    /// - parameter nearbyPlaceEntity: NearbyPlaceEntity object corresponding to the selected object.
    fileprivate func saveDataToSharedContainer(nearbyPlaceEntity : NearbyPlaceEntity)
    {
        if let sharedContainer = self.sharedContainer
        {
            var dataArray = self.fetchDataFromSharedContainer()
            if dataArray == nil
            {
                dataArray = [Any]()
                //--------------------------------------------------------------------------//
                ////Uncomment this if you want to show widget when data is available to show in the widget////////
//                DispatchQueue.main.async(execute: {
//                    NCWidgetController.widgetController().setHasContent(true, forWidgetWithBundleIdentifier: "com.infoedge.NearbyRestaurantsSample.NearbyRestaurantsTodayExtension")
//                })
                //--------------------------------------------------------------------------//
            }
            else
            {
                for data in dataArray!
                {
                    let placeEntity = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! NearbyPlaceEntity
                    if placeEntity.placeID == nearbyPlaceEntity.placeID
                    {
                        return
                    }
                }
                if dataArray!.count == self.totalCountAllowed
                {
                    dataArray!.removeFirst()
                }
            }
            dataArray!.append(NSKeyedArchiver.archivedData(withRootObject: nearbyPlaceEntity))
            sharedContainer.set(true, forKey: "UpdateRequired")
            sharedContainer.set(dataArray, forKey: "NearbyRestaurantsArray")
            sharedContainer.synchronize()
        }
    }
    
    //MARK: Button Action Methods
    @IBAction func refreshResults(_ sender: UIBarButtonItem?)
    {
        self.currentLocation = LocationManager.sharedManager.currentLocation()
        self.loadDataFromServer()
    }
}

// MARK: - UITableViewDataSource Methods
extension NearbyRestaurantsViewController : UITableViewDataSource, UITableViewDelegate
{
    ///UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.nearbyRestaurantsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nearbyPlace", for: indexPath) as! NearbyPlaceTableViewCell
        
        cell.nameLabel.text = self.nearbyRestaurantsArray[indexPath.row].name
        cell.addressLabel.text = self.nearbyRestaurantsArray[indexPath.row].address
        
        if let urlString = self.nearbyRestaurantsArray[indexPath.row].icon
        {
            if let cachedFileData = Cacher.cachedDataforKey(urlString)
            {
                let image = UIImage(data: cachedFileData)
                cell.iconImageView.image = image
            }
            else
            {
                if let url = URL(string: urlString)
                {
                    let urlRequest = URLRequest(url: url)
                    NSURLConnection.sendAsynchronousRequest(urlRequest, queue: OperationQueue.main, completionHandler: {(response, data, error) in
                        if let imageData = data, let builderLogoImage = UIImage(data: imageData)
                        {
                            Cacher.cacheData(imageData, forKey: urlString)
                            cell.iconImageView.image = builderLogoImage
                        }
                        else
                        {
                            cell.iconImageView.image = #imageLiteral(resourceName: "RestaurantIcon")
                        }
                    })
                }
                else
                {
                    cell.iconImageView.image = #imageLiteral(resourceName: "RestaurantIcon")
                }
            }
        }
        else
        {
            cell.iconImageView.image = #imageLiteral(resourceName: "RestaurantIcon")
        }
        return cell
    }
    
    ///UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.saveDataToSharedContainer(nearbyPlaceEntity: self.nearbyRestaurantsArray[indexPath.row])
        let detailController : NearbyRestaurantDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "NearbyRestaurantDetailViewController") as! NearbyRestaurantDetailViewController
        detailController.nearbyRestaurantID = self.nearbyRestaurantsArray[indexPath.row].placeID
        self.navigationController?.pushViewController(detailController, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate Methods
extension NearbyRestaurantsViewController : CLLocationManagerDelegate
{
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        switch status
        {
        case .authorizedWhenInUse:
            self.refreshResults(nil)
        case .denied, .restricted:
            print("Your app is not permitted to use location services. Change your app settings if you want to use location services.")
        default:
            break
        }
    }
}
