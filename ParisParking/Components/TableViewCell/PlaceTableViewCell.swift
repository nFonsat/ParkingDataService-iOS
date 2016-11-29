//
//  PlaceTableViewCell.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 29/11/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addrLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    func setPlace(_ place: Place) {
        self.addrLabel?.text = place.address;
        if let distance = place.meters {
            self.distanceLabel?.text = "\(distance)m";
        }
        else {
            self.distanceLabel.isHidden = true;
        }
        
    }
    
}
