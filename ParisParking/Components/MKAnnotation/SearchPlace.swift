//
//  SearchPlace.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 29/11/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import UIKit
import CoreLocation

class SearchPlace: Place {
    init(_ address:String, coord:CLLocationCoordinate2D) {
        super.init("Unknown", address: address, coord: coord);
    }
}
