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

class Parking : NSObject, MKAnnotation {
    
    let idApi: String;
    let coordinate: CLLocationCoordinate2D;
    
    var nbPlace: Int!;
    var type: String!;
    var regime: String!;
    var stationnement: String!;
    
    init(id: String, coord:CLLocationCoordinate2D) {
        self.idApi = id;
        self.coordinate = coord;
        super.init();
    }
    
    var title: String? {
        return self.idApi
    }
}
