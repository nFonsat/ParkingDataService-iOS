//
//  ParkingDataService.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 01/12/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class ParkingDataService {
    
    private let webService:WebParkingService = WebParkingService.shared;
    
    var userDevice:String?
    var userToken:String?
    
    //MARK: Shared Instance
    
    static let shared : ParkingDataService = {
        let instance = ParkingDataService();
        return instance;
    }()
    
    func getUserToken(phone:String) -> DataRequest {
        let url = "/user/token";
        
        let parameters: Parameters = [
            "phoneId": phone
        ]
        
        return self.webService.post(url, parameters: parameters)
            .responseJSON(completionHandler: { (response) in
                if let error = response.result.error {
                    print("JSON POST USER ERROR : \(error.localizedDescription)");
                    self.userToken = nil;
                    self.userDevice = nil;
                }
                else if let result = response.result.value {
                    let json = JSON(result);
                    if let values = json["result"].array {
                        let value = values[0];
                        if let device = value["device"].string {
                            self.userDevice = device;
                        }
                        if let token = value["token"].string {
                            self.userToken = token;
                        }
                    }
                }
            })
    }
    
}
