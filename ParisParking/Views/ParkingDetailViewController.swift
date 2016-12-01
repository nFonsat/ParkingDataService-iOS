//
//  ParkingDetailViewController.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 01/12/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SwiftyJSON

class ParkingDetailViewController: UIViewController {
    
    @IBOutlet weak var placeMapView: MKMapView!
    @IBOutlet weak var stepTableView: UITableView!
    @IBOutlet weak var navigateBtn: UIButton!
    
    let cellId = "StepRouteCell"
    
    let locationManager: CLLocationManager = CLLocationManager();

    let parkingService:ParkingDataService = ParkingDataService.shared;
    
    var hasFinishRendering:Bool = false;
    
    var parking:Parking!
    var routes:[MKRoute]!
    var route:MKRoute!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false;
        
        self.initMapView();
        self.placeMapView.add((routes.first?.polyline)!);
        
        self.initTableView();
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.route = routes.first;
        hasFinishRendering = true;
        self.stepTableView.reloadData();
    }
    
    @IBOutlet weak var navigateAction: UITableView!
    func askAvailabality() {
        let alertCtrl:UIAlertController = UIAlertController(title: "Available", message: "Is there available place ?", preferredStyle: .alert);
        alertCtrl.addAction(UIAlertAction(title: "Nothing", style: .default, handler: { (action) in
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

extension ParkingDetailViewController : CLLocationManagerDelegate {
    func coreLocationInit() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate = self;
        authorizationCoreLocation()
    }
    
    func authorizationCoreLocation() {
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
    }
}

extension ParkingDetailViewController : MKMapViewDelegate {
    
    func initMapView() {
        coreLocationInit()
        self.placeMapView.delegate = self
        self.placeMapView.showsUserLocation = true
        self.placeMapView.mapType = MKMapType(rawValue: 0)!
        self.placeMapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        
        /*let template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png";
         self.mapViewTemplate(template);*/
    }
    
    func mapViewTemplate(_ template: String) {
        let overlay  = MKTileOverlay(urlTemplate: template)
        overlay.canReplaceMapContent = true
        
        self.placeMapView.add(overlay, level: .aboveLabels)
    }
    
    func zoomOnMap(_ location: CLLocationCoordinate2D, meters: Double) {
        let region:MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(location, meters, meters);
        self.placeMapView.setRegion(region, animated: true);
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if fullyRendered {
            self.placeMapView.showAnnotations([parking, self.placeMapView.userLocation], animated: true);
        }
        hasFinishRendering = fullyRendered;
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKTileOverlay.self) {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        else if overlay.isKind(of: MKPolyline.self) {
            let renderer:MKPolylineRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline);
            renderer.strokeColor = UIColor.brown;
            renderer.lineWidth = 3;
            return renderer;
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
}

extension ParkingDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func initTableView() {
        self.stepTableView.delegate = self;
        self.stepTableView.dataSource = self;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.route.steps.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellId);
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellId);
        }
        
        let step:MKRouteStep = self.route.steps[indexPath.row];
        cell?.textLabel?.text = step.instructions;
        
        return cell!;
    }
    
}
