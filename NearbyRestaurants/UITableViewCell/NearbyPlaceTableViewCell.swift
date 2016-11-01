//
//  NearbyPlaceTableViewCell.swift
//  NearbyPlaces
//
//  Created by Payal Gupta on 10/18/16.
//  Copyright © 2016 Infoedge Pvt. Ltd. All rights reserved.
//

import UIKit

public class NearbyPlaceTableViewCell: UITableViewCell
{
    //MARK: Outlets
    @IBOutlet public weak var iconImageView: UIImageView!
    @IBOutlet public weak var addressLabel: UILabel!
    @IBOutlet public weak var nameLabel: UILabel!
    
    //MARK: View Lifecycle Methods
    override public func awakeFromNib()
    {
        super.awakeFromNib()
        self.iconImageView.image = UIImage(named: "RestaurantIcon")
        self.nameLabel.text = nil
        self.addressLabel.text = nil
    }
}
