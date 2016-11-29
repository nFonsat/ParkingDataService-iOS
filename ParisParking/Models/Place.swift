//
//  Place.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 29/11/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class Place: NSObject, MKAnnotation {
    
    let idApi: String;
    let address: String;
    let coordinate: CLLocationCoordinate2D;
    
    var meters: Int?
    
    init(_ id: String, address:String, coord:CLLocationCoordinate2D) {
        self.idApi = id;
        self.address = address;
        self.coordinate = coord;
        super.init();
    }
    
    var title: String? {
        return self.address
    }
}