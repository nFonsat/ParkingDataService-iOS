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
    
    private let base = "http://192.168.1.8";
    //private let base = "http://10.33.1.131";
    
    //MARK: Shared Instance
    
    static let shared : GeoPointService = {
        let instance = GeoPointService();
        return instance;
    }()
    
    func parkings(min:CLLocationCoordinate2D, max:CLLocationCoordinate2D, center:CLLocationCoordinate2D) -> DataRequest {
        let xMin = min.latitude;
        let yMin = min.longitude;
        
        let xMax = max.latitude;
        let yMax = max.longitude;
        
        let xCenter = center.latitude;
        let yCenter = center.longitude;
        
        let limit = 2000;
        
        let url = self.base.appending("/parking/bounds/\(xMin)/\(yMin)/\(xMax)/\(yMax)?limit=\(limit)&center=\(xCenter);\(yCenter)");
        
        print("New request : \(url)");
        return Alamofire.request(url);
    }
}
