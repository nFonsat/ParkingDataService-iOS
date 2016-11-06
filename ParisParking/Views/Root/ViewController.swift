//
//  ViewController.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 07/09/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapViewInit()
        
        /*
        let template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
        self.mapViewTemplate(template)
        */
        
        self.title = "Paris..."
        
        let searchItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(ViewController.goToSearchView))
        let filterItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(ViewController.filterModal))
        self.navigationItem.rightBarButtonItems = [searchItem, filterItem];
    }
    
    func goToSearchView() {
        let searchViewController = SearchViewController()
        self.navigationController?.pushViewController(searchViewController, animated: true)
    }
    
    func filterModal() {
        print("--goToSearchView")
    }
    
    func coreLocationInit() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self;
        authorizationCoreLocation()
    }
    
    func authorizationCoreLocation() {
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    /*
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        print("present location : (newLocation.coordinate.latitude), (newLocation.coordinate.longitude)")
    }
    */
    
    func mapViewInit() {
        coreLocationInit()
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
    }
    
    func mapViewTemplate(_ template: String) {
        let overlay  = MKTileOverlay(urlTemplate: template)
        overlay.canReplaceMapContent = true
        
        mapView.add(overlay, level: .aboveLabels)
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKTileOverlay.self) {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
}

