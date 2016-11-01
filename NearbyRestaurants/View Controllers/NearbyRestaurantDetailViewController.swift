//
//  NearbyRestaurantDetailViewController.swift
//  NearbyRestaurants
//
//  Created by Payal Gupta on 10/19/16.
//  Copyright © 2016 Infoedge Pvt. Ltd. All rights reserved.
//

import UIKit
import NearbyPlaces

class NearbyRestaurantDetailViewController: UIViewController
{
    //MARK: Outlets
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var contact: UILabel!
    @IBOutlet weak var openOrClosed: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    //MARK: Private Properties
    fileprivate let kCellSpacing : CGFloat = 5
    fileprivate let kCellInset : CGFloat = 15
    fileprivate var nearbyRestaurantDetail : NearbyPlaceDetail?


    //MARK: Internal Properties
    var nearbyRestaurantID : String?

    //MARK: View Lifecycle Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.name.text = nil
        self.address.text = nil
        self.contact.text = nil
        self.openOrClosed.isHidden = true
        self.photosCollectionView.isHidden = true
        
        self.loadDataFromServer()
    }
    
    /// This Method sends the Google Place Detail API hit and the response is then saved in "self.nearbyPlaceDetailObject" and reloads the table view
    fileprivate func loadDataFromServer()
    {
        self.activityIndicator.startAnimating()
        NearbyPlaceDetail.fetchNearByPlaceDetailForPlaceID(self.nearbyRestaurantID!) { (responseObject, error) in
            self.activityIndicator.stopAnimating()
            guard let nearbyRestaurantDetail = responseObject as? NearbyPlaceDetail else
            {
                if error != nil
                {
                    let alert = UIAlertView.init(title: "Alert", message: (error?.localizedDescription)!, delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }

                return
            }
            self.nearbyRestaurantDetail = nearbyRestaurantDetail
            self.photosCollectionView.isHidden = false
            self.openOrClosed.isHidden = false
            self.photosCollectionView.reloadData()
            self.updateRestaurantDetails()
        }
    }
    
    private func updateRestaurantDetails()
    {
        self.name.text = nearbyRestaurantDetail?.name
        self.address.text = nearbyRestaurantDetail?.completeAddress
        if let contact = nearbyRestaurantDetail?.phoneNumber
        {
            self.contact.text = "Contact : \(contact)"
        }
        if (nearbyRestaurantDetail?.permanentlyClosed)!
        {
            self.openOrClosed.text = "Permanently Closed"
        }
        else
        {
            if (nearbyRestaurantDetail?.openNow)!
            {
                self.openOrClosed.text = "Open Now"
            }
            else
            {
                self.openOrClosed.text = "Closed Now"
            }
        }
    }
}

// MARK: - UICollectionViewDataSource Methods
extension NearbyRestaurantDetailViewController : UICollectionViewDataSource, UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.nearbyRestaurantDetail?.photosIDs?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = self.photosCollectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! NearbyRestaurantPhotoCollectionViewCell

        if let photosIDs = self.nearbyRestaurantDetail?.photosIDs
        {
            let photoID = photosIDs[indexPath.row]
            let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(Int(UIScreen.main.bounds.width))&photoreference=\(photoID)&key=AIzaSyA-80bYgdT6jJdi-K7SQQ4gqkHms3t4jP4"
            
            if let url = URL(string: urlString)
            {
                let urlRequest = URLRequest(url: url)
                NSURLConnection.sendAsynchronousRequest(urlRequest, queue: OperationQueue.main, completionHandler: {(response, data, error) in
                    if let data = data
                    {
                        let image = UIImage(data: data)
                        cell.photoImageView.image = image
                    }
                    else
                    {
                        cell.photoImageView.image = #imageLiteral(resourceName: "GalleryPlaceholder")
                    }
                })
            }
        }
        else
        {
            cell.photoImageView.image = #imageLiteral(resourceName: "GalleryPlaceholder")
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout Methods
extension NearbyRestaurantDetailViewController : UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let cellSize = CGSize(width: self.photosCollectionView.bounds.width - (2 * kCellSpacing) - (2 * kCellInset) , height: self.photosCollectionView.bounds.height)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return kCellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        let sectionInset = UIEdgeInsetsMake(0, kCellSpacing + kCellInset, 0, kCellSpacing + kCellInset)
        return sectionInset
    }
}
