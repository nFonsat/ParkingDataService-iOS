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
    
    //private let base = "http://192.168.1.41";
    private let base = "http://10.33.1.131";
    
    //MARK: Shared Instance
    
    static let shared : GeoPointService = {
        let instance = GeoPointService();
        return instance;
    }()
    
    
    func parkings(center:CLLocationCoordinate2D) -> DataRequest {
        let lat = center.latitude;
        let lng = center.longitude;
        let distance = 5;
        let limit = 20;
        
        let url = self.base.appending("/parking/position/\(lat)/\(lng)?distance=\(distance)&limit=\(limit)");
        
        print("New request : \(url)");
        return Alamofire.request(url);
    }
    
    
    func parkings(min:CLLocationCoordinate2D, max:CLLocationCoordinate2D) -> DataRequest {
        let xMin = min.latitude;
        let yMin = min.longitude;
        
        let xMax = max.latitude;
        let yMax = max.longitude;
        
        let limit = 1000;
        
        let url = self.base.appending("/parking/bounds/\(xMin)/\(yMin)/\(xMax)/\(yMax)?limit=\(limit)");
        
        print("New request : \(url)");
        return Alamofire.request(url);
    }
}
