//
//  ParkingDetailViewController.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 01/12/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import UIKit
import MapKit;
import SwiftyJSON

class ParkingDetailViewController: UIViewController {
    
    let parkingService:ParkingDataService = ParkingDataService.shared;
    
    var parking:Parking!
    var routes:[MKRoute]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.parkingService.avaibility(parking)
            .responseJSON { (response) in
                if let error = response.result.error {
                    print("avaibility -- Error : \(error.localizedDescription)");
                }
                else if let result = response.result.value {
                    let json = JSON(result);
                    print("avaibility -- JSON : \(json)");
                }
            }
        
        print("Route found : \(routes.count)");
        for route:MKRoute in routes {
            print("\(route.name) -- \(route.distance) -- \(route.expectedTravelTime)");
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.askAvailabality();
    }
    
    func askAvailabality() {
        let alertCtrl:UIAlertController = UIAlertController(title: "Available", message: "Is there available place ?", preferredStyle: .alert);
        alertCtrl.addAction(UIAlertAction(title: "Nothing place", style: .default, handler: { (action) in
            self.setAvalability(0);
        }));
        alertCtrl.addAction(UIAlertAction(title: "25% of place", style: .default, handler: { (action) in
            self.setAvalability(25);
        }));
        alertCtrl.addAction(UIAlertAction(title: "50% of place", style: .default, handler: { (action) in
            self.setAvalability(50);
        }));
        alertCtrl.addAction(UIAlertAction(title: "75% of place", style: .default, handler: { (action) in
            self.setAvalability(75);
        }));
        alertCtrl.addAction(UIAlertAction(title: "All place available", style: .default, handler: { (action) in
            self.setAvalability(100);
        }));
        alertCtrl.addAction(UIAlertAction(title: "I don't know", style: .destructive, handler: nil));
        self.present(alertCtrl, animated: true, completion: nil);
    }
    
    func setAvalability(_ level: Int) {
        self.parkingService.postAvaibility(parking, level: level)
            .responseJSON { (response) in
                if let error = response.result.error {
                    print("avaibility -- Error : \(error.localizedDescription)");
                }
                else if let result = response.result.value {
                    let json = JSON(result);
                    print("avaibility -- JSON : \(json)");
                }
            }
    }

}
