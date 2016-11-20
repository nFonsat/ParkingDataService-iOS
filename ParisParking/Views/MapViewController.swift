//
//  MapViewController.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 07/09/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SwiftyJSON

class MapViewController: UIViewController  {

    @IBOutlet weak var mapView: MKMapView!
    
    let clusteringManager = FBClusteringManager();
    let configuration     = FBAnnotationClusterViewConfiguration.default();
    
    let locationManager: CLLocationManager = CLLocationManager();
    
    let geoService:GeoPointService = GeoPointService.shared;
    
    var hasFinishRendering = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapViewInit()
        
        clusteringManager.delegate = self;
        
        /*
        let template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
        self.mapViewTemplate(template)
        */
        
        self.title = "Paris..."
        
        let searchItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(MapViewController.goToSearchView))
        let filterItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(MapViewController.filterModal))
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
}

extension MapViewController : CLLocationManagerDelegate {
    func coreLocationInit() {
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
}

extension MapViewController : FBClusteringManagerDelegate {
    
    func cellSizeFactor(forCoordinator coordinator:FBClusteringManager) -> CGFloat {
        return 1.0
    }
}

extension MapViewController : MKMapViewDelegate {
    
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
                self.clusteringManager.removeAll();
                self.clusteringManager.add(annotations: parkings);
                DispatchQueue.global(qos: .userInitiated).async {
                    let mapBoundsWidth = Double(self.mapView.bounds.size.width)
                    let mapRectWidth = self.mapView.visibleMapRect.size.width
                    let scale = mapBoundsWidth / mapRectWidth
                    
                    let annotationArray = self.clusteringManager.clusteredAnnotations(withinMapRect: self.mapView.visibleMapRect, zoomScale:scale)
                    
                    DispatchQueue.main.async {
                        self.clusteringManager.display(annotations: annotationArray, onMapView:self.mapView)
                    }
                }
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKTileOverlay.self) {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var reuseId = ""
        
        if annotation is FBAnnotationCluster {
            
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if clusterView == nil {
                clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, configuration: self.configuration)
            } else {
                clusterView?.annotation = annotation
            }
            
            return clusterView
            
        }
        
        return nil;
    }
}

