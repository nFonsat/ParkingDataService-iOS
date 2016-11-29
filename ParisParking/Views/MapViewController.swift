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
    
    @IBOutlet weak var placeMapView: MKMapView!
    @IBOutlet weak var placeTableView: UITableView!
    
    let cellId: String = "PlaceCell";
    
    let clusteringManager = FBClusteringManager();
    let configuration     = FBAnnotationClusterViewConfiguration.default();
    
    let locationManager: CLLocationManager = CLLocationManager();
    
    let geoService:GeoPointService = GeoPointService.shared;
    
    var hasFinishRendering = false;
    
    var places:[Parking] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
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
    
    func alertForParking(_ parking: Parking) {
        let alertCtrl:UIAlertController = UIAlertController(title: "Choose", message: "Choose your action ?", preferredStyle: .actionSheet);
        alertCtrl.addAction(UIAlertAction(title: "GO", style: .default, handler: { (action) in
            self.placeMapView.showAnnotations([parking, self.placeMapView.userLocation], animated: true);
            self.goToPlace(parking);
        }));
        alertCtrl.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil));
        self.present(alertCtrl, animated: true, completion: nil);
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
    
    func getParkings(bottom: CLLocationCoordinate2D, top: CLLocationCoordinate2D,  center: CLLocationCoordinate2D) {
        var parkings:[Parking] = []
        
        self.geoService.parkings(min: bottom, max: top, center: center).responseJSON { response in
            var count = 0;
            self.places.removeAll();
            if let result = response.result.value {
                let jsonResult = JSON(result);
                for value in jsonResult["result"].array! {
                    let parking:Parking = ParkingFactory.getParkingFromJson(value.object as! [String : AnyObject]);
                    parkings.append(parking);
                    if count < 10 {
                        self.places.append(parking);
                        count+=1;
                    }
                }
            }
            print("-- getParkings() : \(top.latitude);\(top.longitude) <=> \(bottom.latitude);\(bottom.longitude) -- \(parkings.count)");
            
            DispatchQueue.main.async(execute: {
                self.clusteringManager.removeAll();
                self.clusteringManager.add(annotations: parkings);
                self.placeTableView.reloadData();
                DispatchQueue.global(qos: .userInitiated).async {
                    let mapBoundsWidth = Double(self.placeMapView.bounds.size.width)
                    let mapRectWidth = self.placeMapView.visibleMapRect.size.width
                    let scale = mapBoundsWidth / mapRectWidth
                    
                    let annotationArray = self.clusteringManager.clusteredAnnotations(withinMapRect: self.placeMapView.visibleMapRect, zoomScale:scale)
                    
                    DispatchQueue.main.async {
                        self.clusteringManager.display(annotations: annotationArray, onMapView:self.placeMapView)
                    }
                }
            })
        }
    }
    
    func mapViewInit() {
        coreLocationInit()
        self.placeMapView.delegate = self
        self.placeMapView.showsUserLocation = true
        self.placeMapView.mapType = MKMapType(rawValue: 0)!
        self.placeMapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
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
    
    func goToPlace(_ place:Parking) {
        let request:MKDirectionsRequest = MKDirectionsRequest();
        request.source = MKMapItem.forCurrentLocation();
        
        if #available(iOS 10.0, *) {
            let destination:MKPlacemark = MKPlacemark(coordinate: place.coordinate);
            request.destination = MKMapItem(placemark: destination);
        } else {
            let destination:MKPlacemark = MKPlacemark(coordinate: place.coordinate, addressDictionary: nil);
            request.destination = MKMapItem(placemark: destination);
        };
        
        
        request.transportType = .automobile;
        
        let directions:MKDirections = MKDirections(request: request);
        directions.calculate { (response, error) in
            if let msg = error {
                print("Error - goToPlace", msg.localizedDescription);
            }
            else if response != nil {
                let details:MKRoute = (response?.routes.last)!;
                
                self.placeMapView.removeOverlays(self.placeMapView.overlays);
                self.placeMapView.add(details.polyline);
                
                for step:MKRouteStep in details.steps {
                    print("\(step.instructions) -- \(step.distance)");
                }
            }
        }
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        hasFinishRendering = fullyRendered;
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if hasFinishRendering {
            let bounds = self.placeMapView.getBoundingBox();
            let top = bounds[0];
            let bottom = bounds[1];
            let userLoc = self.placeMapView.userLocation;
            self.getParkings(bottom: bottom, top: top, center: userLoc.coordinate);
        }
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

extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    
    func initTableView() {
        let nib:UINib = UINib(nibName: "PlaceTableViewCell", bundle: nil);
        self.placeTableView.register(nib, forCellReuseIdentifier: cellId);
        
        self.placeTableView.delegate = self;
        self.placeTableView.dataSource = self;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.places.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PlaceTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellId) as! PlaceTableViewCell;
        
        let place = self.places[indexPath.row];
        cell.setPlace(place);
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = self.places[indexPath.row];
        self.zoomOnMap(place.coordinate, meters: 3);
        self.alertForParking(place);
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50;
    }
    
}

