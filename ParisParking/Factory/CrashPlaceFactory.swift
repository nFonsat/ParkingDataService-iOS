//
//  CrashPlaceFactory.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 30/11/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import Foundation
import SwiftyJSON

class CrashPlaceFactory {
    class func getChargingPointFromJson(_ data: JSON) -> CrashPlace {
        let crash:CrashPlace = CrashPlace(place: PlaceFactory.getPlaceFromJson(data));
        
        if let value = data["creation"].string {
            if !value.isEmpty {
                let formater:DateFormatter = DateFormatter();
                formater.dateFormat = "yyyy-MM-dd HH:mm:ssZ";
                let date = formater.date(from: value);
                crash.creation = date;
            }
        }
        
        return crash;
    }
}
