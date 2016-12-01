//
//  FuelStationFactory.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 30/11/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import Foundation
import SwiftyJSON


class FuelStationFactory {
    
    class func getFuelStationFromJson(_ data: JSON) -> FuelStation {
        let station:FuelStation = FuelStation(place: PlaceFactory.getPlaceFromJson(data));
        
        if let value = data["name_station"].string {
            station.name = value;
        }
        
        if let value = data["brand"].string {
            station.brand = value;
        }
        
        if let schedules:[String] = data["schedule"].string?.components(separatedBy: ",") {
            station.openDate  = schedules[0];
            station.closeDate = schedules[1];
        }
        
        if let value = data["last_update"].string {
            let formater:DateFormatter = DateFormatter();
            formater.dateFormat = "yyyy-MM-dd HH:mm:ssZ";
            let date = formater.date(from: value);
            station.updated = date;
        }
        
        if let opening:String = data["opening"].string {
            station.opening = opening.components(separatedBy: ":");
        }
        
        if let gazole = data["gazole"].string {
            station.gazole = Float(gazole);
        }
        
        if let sp95 = data["sp95"].string {
            station.sp95 = Float(sp95);
        }
        
        if let sp98 = data["sp98"].string {
            station.sp98 = Float(sp98);
        }
        
        if let gpl = data["gpl"].string {
            station.gpl = Float(gpl);
        }
        
        if let e10 = data["e10"].string {
            station.e10 = Float(e10);
        }
        
        if let e85 = data["e85"].string {
            station.e85 = Float(e85);
        }
        
        return station;
    }
    
}
