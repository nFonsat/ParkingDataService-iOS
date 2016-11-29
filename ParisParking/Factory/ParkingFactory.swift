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
        let address:String = data["address_geo"] as! String;
        let isParc:Bool = data["is_parc"] as! Bool;
        let typeParking:String = data["type_parking"] as! String;
        let typeStationnement:String = data["type_stationnement"] as! String;
        let posStationnement:String = data["position_stationnement"] as! String;
        let lat = Double(data["lat"] as! String);
        let lng = Double(data["lng"] as! String);
        let distance = Double((data["distance"] as? String)!);
        
        let parking:Parking = Parking(id, address: address, coord: CLLocationCoordinate2DMake(lat!, lng!));
        
        parking.name = data["name_parking"] as? String;
        parking.isParc = isParc;
        parking.typeParking = typeParking;
        parking.posStationnement = posStationnement;
        parking.typeStationnement = typeStationnement;
        
        parking.meters = lround(distance!);
        
        return parking;
    }
}
