//
//  Parking.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 06/11/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class Parking : Place {
    
    var name: String?
    var isParc: Bool!
    var typeParking: String?
    var typeStationnement: String?
    var posStationnement: String?
    
    override var image: String {
        get {
            return "park-locate"
        }
        set {}
    }
    

}
