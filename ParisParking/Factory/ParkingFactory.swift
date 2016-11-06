//
//  ParkingFactory.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 06/11/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

class ParkingFactory {
    
    class func getParkingFromJson(_ data: [String:AnyObject]) -> Parking {
        let id:String = data["id_api"] as! String;
        
        let lat = Double(data["st_x"] as! String);
        let lng = Double(data["st_y"] as! String);
        
        let parking:Parking = Parking(id: id, coord: CLLocationCoordinate2DMake(lat!, lng!))
        
        parking.nbPlace = data["nb_place"] as! Int;
        parking.type = data["type_parking"] as! String;
        parking.regime = data["regime_id_regime"] as! String;
        parking.stationnement = data["id_type_stationnement"] as! String;
        
        return parking;
    }
}
