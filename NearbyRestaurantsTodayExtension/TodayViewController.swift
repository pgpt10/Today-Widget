//
//  TodayViewController.swift
//  NearbyRestaurantsTodayExtension
//
//  Created by Payal Gupta on 10/20/16.
//  Copyright © 2016 Infoedge Pvt. Ltd. All rights reserved.
//

import UIKit
import NotificationCenter
import NearbyPlaces

class TodayViewController: UIViewController
{
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showMoreButton: UIButton!

    //MARK: Private Properties
    fileprivate let kCellHeight : CGFloat = 84.0
    fileprivate var nearbyRestaurantsArray = [NearbyPlaceEntity]()
    private let kAppGroupName = "group.com.infoedge.NearbyRestaurantsSample"
    private var sharedContainer : UserDefaults?
    private var tableViewHeightConstraint : NSLayoutConstraint?
    
    //MARK: View Lifecycle Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.sharedContainer = UserDefaults(suiteName: kAppGroupName)
        self.fetchDataFromSharedContainer()
        self.tableView.reloadData()

        if #available(iOSApplicationExtension 10.0, *)
        {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
            self.showMoreButton.removeFromSuperview()
        }
        else
        {
            self.tableViewHeightConstraint = NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: kCellHeight)
            let refreshButtonHeightConstraint = NSLayoutConstraint(item: self.showMoreButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 44)
            NSLayoutConstraint.activate([tableViewHeightConstraint!, refreshButtonHeightConstraint])
        }
    }
    
    //MARK: Private Methods
    /// This method fetches the data to be displayed in widget from shared container.
    fileprivate func fetchDataFromSharedContainer()
    {
        if let sharedContainer = self.sharedContainer, let dataArray = sharedContainer.array(forKey: "NearbyRestaurantsArray")
        {
            self.nearbyRestaurantsArray = []
            for data in dataArray
            {
                self.nearbyRestaurantsArray.append(NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! NearbyPlaceEntity)
            }
        }
    }
    
    /// This method checks if the widget data updation is required. It fetches "UpdateRequired" from shared container and returns it. Also it resets "UpdateRequired" in the shared container.
    ///
    /// - returns: true, if data updation is required. false, if data updation is not required
    fileprivate func isUpdateRequired() -> Bool
    {
        if let sharedContainer = self.sharedContainer
        {
            let isUpdateRequired = sharedContainer.bool(forKey: "UpdateRequired")
            if isUpdateRequired
            {
                sharedContainer.set(false, forKey: "UpdateRequired")
                sharedContainer.synchronize()
                return true
            }
        }
        return false
    }
    
    //MARK: Button Action Methods
    @IBAction func showMoreRestaurants(_ sender: UIButton)
    {
        self.fetchDataFromSharedContainer()
        self.tableView.reloadData()
        if self.nearbyRestaurantsArray.count <= 1
        {
            return
        }
        
        if sender.isSelected
        {
            self.tableViewHeightConstraint?.constant = kCellHeight
            sender.isSelected = false
        }
        else
        {
            self.tableViewHeightConstraint?.constant = kCellHeight * CGFloat(self.nearbyRestaurantsArray.count)
            sender.isSelected = true
        }
    }
}

// MARK: - UITableViewDataSource Methods
extension TodayViewController : UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.nearbyRestaurantsArray.count == 0
        {
            return 1
        }
        return self.nearbyRestaurantsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "nearbyRestaurantCell", for: indexPath)
        if #available(iOS 10.0, *)
        {
            cell.textLabel?.textColor = UIColor.darkGray
            cell.detailTextLabel?.textColor = UIColor.darkGray
        }
        else
        {
            cell.textLabel?.textColor = UIColor.lightGray
            cell.detailTextLabel?.textColor = UIColor.lightGray
        }
        cell.textLabel?.text = (self.nearbyRestaurantsArray.count == 0) ? nil : self.nearbyRestaurantsArray[indexPath.row].name
        cell.detailTextLabel?.text = (self.nearbyRestaurantsArray.count == 0) ? "No recently viewed restaurants. Tap and open the app to view nearby restaurant." : self.nearbyRestaurantsArray[indexPath.row].address
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.tableView.cellForRow(at: indexPath)?.isSelected = false
        self.extensionContext?.open(URL(string: "NearbyRestaurantsTodayExtension://\((self.nearbyRestaurantsArray.count == 0) ? "" : self.nearbyRestaurantsArray[indexPath.row].placeID)")!, completionHandler: nil)
    }
}

// MARK: - NCWidgetProviding Methods
extension TodayViewController : NCWidgetProviding
{
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets
    {
        return UIEdgeInsets.zero
    }
    
    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Swift.Void)
    {
        if self.isUpdateRequired()
        {
            self.fetchDataFromSharedContainer()
            self.tableView.reloadData()
            completionHandler(NCUpdateResult.newData)
        }
        else
        {
            completionHandler(NCUpdateResult.noData)
        }
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize)
    {
        if activeDisplayMode == .expanded
        {
            preferredContentSize = CGSize(width: 0.0, height: kCellHeight * CGFloat(self.nearbyRestaurantsArray.count) + 16)
        }
        else
        {
            preferredContentSize = maxSize
        }
    }
}
