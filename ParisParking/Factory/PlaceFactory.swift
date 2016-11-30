//
//  PlaceFactory.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 30/11/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation


class PlaceFactory {
    
    class func getPlaceFromJson(_ data: JSON) -> Place {
        let address:String = data["address_geo"].string!;
        let lat = Double(data["lat"].string!);
        let lng = Double(data["lng"].string!);
        
        let place:Place = Place(address: address, coord: CLLocationCoordinate2DMake(lat!, lng!));
        
        if let id:String = data["id_api"].string {
            place.idApi = id;
        }
        
        if let distance:Double = data["distance"].double {
            place.meters = lround(distance);
        }
        
        return place;
    }
    
}
