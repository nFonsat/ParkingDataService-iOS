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
        
        let lat = Double(data["lat"] as! String);
        let lng = Double(data["lng"] as! String);
        
        let parking:Parking = Parking(id: id, coord: CLLocationCoordinate2DMake(lat!, lng!))
        
        //parking.nbPlace = data["total_place"] as! Int;
        parking.type = data["type_parking"] as! String;
        parking.regime = data["regime"] as! String;
        parking.stationnement = data["type_stationnement"] as! String;
        
        return parking;
    }
}
