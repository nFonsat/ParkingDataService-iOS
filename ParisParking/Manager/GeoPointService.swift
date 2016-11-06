//
//  GeoPointService.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 06/11/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import CoreLocation

class GeoPointService {
    
    private let base = "http://192.168.1.41";
    
    //MARK: Shared Instance
    
    static let shared : GeoPointService = {
        let instance = GeoPointService();
        return instance;
    }()
    
    
    func parkings(coord:CLLocationCoordinate2D) -> DataRequest {
        let lat = coord.latitude;
        let lng = coord.longitude;
        let url = self.base.appending("/parking/position/\(lat)/\(lng)");
        
        print("New request : \(url)");
        return Alamofire.request(url);
    }
}
