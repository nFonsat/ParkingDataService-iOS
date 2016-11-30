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
        let url = self.getUrlForBound("parking", min: min, max: max, limit: 3000, center: center);
        
        return self.request(url);
    }
    
    func fuels(min:CLLocationCoordinate2D, max:CLLocationCoordinate2D, center:CLLocationCoordinate2D) -> DataRequest {
        let url = self.getUrlForBound("fuel", min: min, max: max, limit: 50, center: center);
        
        return self.request(url);
    }
    
    private func request(_ url: String) -> DataRequest {
        print("New request : \(url)");
        return Alamofire.request(url);
    }
    
    private func getUrlForBound(_ data:String,  min:CLLocationCoordinate2D, max:CLLocationCoordinate2D, limit:Int , center:CLLocationCoordinate2D) -> String {
        let xMin = min.latitude;
        let yMin = min.longitude;
        
        let xMax = max.latitude;
        let yMax = max.longitude;
        
        let xCenter = center.latitude;
        let yCenter = center.longitude;
        
        let limit = limit;
        
        return self.base.appending("/\(data)/bounds/\(xMin)/\(yMin)/\(xMax)/\(yMax)?limit=\(limit)&center=\(xCenter);\(yCenter)");
    }
}
