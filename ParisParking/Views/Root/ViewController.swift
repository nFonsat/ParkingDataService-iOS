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
import SwiftyJSON

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    
    var geoService:GeoPointService!
    
    var hasFinishRendering = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapViewInit()
        
        self.geoService = GeoPointService.shared;
        
        /*
        let template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
        self.mapViewTemplate(template)
        */
        
        self.title = "Paris..."
        
        let searchItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(ViewController.goToSearchView))
        let filterItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(ViewController.filterModal))
        self.navigationItem.rightBarButtonItems = [searchItem, filterItem];
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hasFinishRendering = false;
    }
    
    func goToSearchView() {
        let searchViewController = SearchViewController()
        self.navigationController?.pushViewController(searchViewController, animated: true)
    }
    
    func filterModal() {
        print("--filterModal")
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
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        hasFinishRendering = fullyRendered;
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if hasFinishRendering {
            let bounds = self.mapView.getBoundingBox();
            let top = bounds[0];
            let bottom = bounds[1];
            self.getParkings(bottom: bottom, top: top);
        }
        
    }
    
    func getParkings(bottom: CLLocationCoordinate2D, top: CLLocationCoordinate2D) {
        var parkings:[Parking] = []
        
        self.geoService.parkings(min: bottom, max: top).responseJSON { response in
            if let result = response.result.value {
                let jsonResult = JSON(result);
                for value in jsonResult["result"].array! {
                    parkings.append(ParkingFactory.getParkingFromJson(value.object as! [String : AnyObject]));
                }
            }
            print("-- getParkings() : \(top.latitude);\(top.longitude) <=> \(bottom.latitude);\(bottom.longitude) -- \(parkings.count)");
            DispatchQueue.main.async(execute: {
                self.mapView.removeAnnotations(self.mapView.annotations);
                self.mapView.addAnnotations(parkings);
            })
        }
    }
    
    func getParkings(center: CLLocation) {
        var parkings:[Parking] = []
        let lat = center.coordinate.latitude;
        let lng = center.coordinate.longitude;
        
        self.geoService.parkings(center: center.coordinate).responseJSON { response in
            if let result = response.result.value {
                let jsonResult = JSON(result);
                for value in jsonResult["result"].array! {
                    parkings.append(ParkingFactory.getParkingFromJson(value.object as! [String : AnyObject]));
                }
            }
            print("-- getParkings() : \(lat), \(lng) -- \(parkings.count)");
            DispatchQueue.main.async(execute: {
                self.mapView.removeAnnotations(self.mapView.annotations);
                self.mapView.addAnnotations(parkings);
                self.mapView.showAnnotations(parkings, animated: true);
            })
        }
    }
    
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

