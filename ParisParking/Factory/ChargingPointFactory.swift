//
//  ChargingPointFactory.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 30/11/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import Foundation
import SwiftyJSON

class ChargingPointFactory {
    
    class func getChargingPointFromJson(_ data: JSON) -> ChargingPoint {
        let point:ChargingPoint = ChargingPoint(place: PlaceFactory.getPlaceFromJson(data));
        
        if let value = data["id_station"].string {
            point.idStation = value;
        }
        
        if let value = data["name_point"].string {
            point.name = value;
        }
        
        if let value = data["owner"].string {
            point.owner = value;
        }
        
        if let value = data["comments"].string {
            point.observation = value;
        }
        
        if let value = data["connector"].string {
            point.connector = value;
        }
        
        if let value = data["fast_charge"].bool {
            point.fast = value;
        }
        
        if let value = data["last_update"].string {
            if !value.isEmpty {
                let formater:DateFormatter = DateFormatter();
                formater.dateFormat = "yyyy-MM-dd HH:mm:ssZ";
                let date = formater.date(from: value);
                point.updated = date;
            }
        }
        
        return point;
    }
    
}
