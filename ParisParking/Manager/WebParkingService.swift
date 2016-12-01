//
//  WebParkingService.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 01/12/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import Foundation
import Alamofire

class WebParkingService {
    //let dataServiceUrl = "http://192.168.1.41";
    let dataServiceUrl:String = "http://10.33.1.167";
    
    static let shared : WebParkingService = {
        let instance = WebParkingService();
        return instance;
    }()
    
    func request(_ url: String) -> DataRequest {
        let urlRequest:String = self.dataServiceUrl + url;
        
        print("[GET] -- \(urlRequest)");
        return Alamofire.request(urlRequest);
    }
    
    func post(_ urlString: String, parameters: Parameters?) -> DataRequest {
        let urlRequest:String = self.dataServiceUrl + urlString;
        let url = URL(string: urlRequest)!;
        
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        print("[POST] -- \(urlRequest)");
        return Alamofire.request(url, method: .post, parameters: parameters, headers: headers);
    }
    
}
