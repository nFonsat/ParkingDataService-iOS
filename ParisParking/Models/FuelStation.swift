//
//  FuelStation.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 30/11/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import UIKit
import CoreLocation

class FuelStation: Place {
    
    var name: String?
    var brand: String?
    var openDate: String?
    var closeDate: String?
    var updated: Date?
    var opening:[String] = []

    var gazole:Float?
    var sp95:Float?
    var sp98:Float?
    var gpl:Float?
    var e10:Float?
    var e85:Float?
    
    override var image: String {
        get {
            return "station-pressed"
        }
        set {}
    }
    
}
