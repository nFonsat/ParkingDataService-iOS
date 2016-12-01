//
//  ParkingDetailViewController.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 01/12/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import UIKit
import MapKit;

class ParkingDetailViewController: UIViewController {
    
    var parking:Parking!
    var routes:[MKRoute]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        alertCtrl.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            print("YES")
        }));
        alertCtrl.addAction(UIAlertAction(title: "I don't know", style: .default, handler: { (action) in
            print("I don't know")
        }));
        alertCtrl.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil));
        self.present(alertCtrl, animated: true, completion: nil);

    }

}
