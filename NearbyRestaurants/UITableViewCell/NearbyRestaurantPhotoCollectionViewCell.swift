//
//  NearbyRestaurantPhotoCollectionViewCell.swift
//  NearbyRestaurants
//
//  Created by Payal Gupta on 10/19/16.
//  Copyright © 2016 Infoedge Pvt. Ltd. All rights reserved.
//

import UIKit

class NearbyRestaurantPhotoCollectionViewCell: UICollectionViewCell
{
    //MARK: Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    
    //MARK: View Lifecycle Methods
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.photoImageView.image = #imageLiteral(resourceName: "GalleryPlaceholder")
    }
}
