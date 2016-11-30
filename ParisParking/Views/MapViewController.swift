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

class MapViewController: DefaultViewController  {
    
    @IBOutlet weak var placeMapView: MKMapView!
    @IBOutlet weak var placeTableView: UITableView!
    @IBOutlet weak var placeSearchBar: UISearchBar!
    
    @IBOutlet weak var parkingBtn: UIButton!
    @IBOutlet weak var fuelBtn: UIButton!
    @IBOutlet weak var electricBtn: UIButton!
    @IBOutlet weak var accidentBtn: UIButton!
    
    let cellId: String = "PlaceCell";
    
    let clusteringManager = FBClusteringManager();
    let configuration     = FBAnnotationClusterViewConfiguration.default();
    
    let locationManager: CLLocationManager = CLLocationManager();
    
    let geoService:GeoPointService = GeoPointService.shared;
    
    var hasFinishRendering = false;
    
    var annotationsParking:[Parking] = [];
    var parkings:[Parking] = [];
    var fuels:[FuelStation] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView();
        initMapView();
        initSearchBar();
        
        self.navigationController?.navigationBar.isHidden = true;
        
        self.parkingBtn.isSelected = true;
        self.fuelBtn.isSelected = false;
        self.electricBtn.isSelected = false;
        self.accidentBtn.isSelected = false;
        
        clusteringManager.delegate = self;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hasFinishRendering = false;
        self.updateMapView();
    }
    
    @IBAction func displayOnMapAction(_ sender: UIButton) {
        sender.isSelected = !(sender.isSelected);
        self.updateMapView();
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
    
    func findAddress(_ address: String) {
        let geocoder:CLGeocoder =  CLGeocoder();
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let msg = error {
                print(msg.localizedDescription);
            }
            else if let places = placemarks, let place:CLPlacemark = places.last, let location:CLLocation = place.location {
                let coordinate:CLLocationCoordinate2D = location.coordinate;
                print("Place found = \(place.name) => \(coordinate.latitude);\(coordinate.longitude)");
                let place:SearchPlace = SearchPlace(place.name!, coord: coordinate);
                self.placeMapView.addAnnotation(place);
                self.zoomOnMap(coordinate, meters: 50);
            }
            else {
                print("No place found");
            }
        }
    }
}

extension MapViewController : FBClusteringManagerDelegate {
    
    func cellSizeFactor(forCoordinator coordinator:FBClusteringManager) -> CGFloat {
        return 1.0
    }
    
    func fbReloadData() {
        DispatchQueue.global(qos: .userInitiated).async {
            let mapBoundsWidth = Double(self.placeMapView.bounds.size.width)
            let mapRectWidth = self.placeMapView.visibleMapRect.size.width
            let scale = mapBoundsWidth / mapRectWidth
            
            let annotationArray = self.clusteringManager.clusteredAnnotations(withinMapRect: self.placeMapView.visibleMapRect, zoomScale:scale)
            
            DispatchQueue.main.async {
                self.clusteringManager.display(annotations: annotationArray, onMapView:self.placeMapView)
            }
        }
    }
}

extension MapViewController : MKMapViewDelegate {
    
    func getParkings(bottom: CLLocationCoordinate2D, top: CLLocationCoordinate2D,  center: CLLocationCoordinate2D) {
        
        self.geoService.parkings(min: bottom, max: top, center: center).responseJSON { response in
            var count = 0;
            self.annotationsParking.removeAll();
            self.parkings.removeAll();
            if let result = response.result.value {
                let jsonResult = JSON(result);
                for value in jsonResult["result"].array! {
                    let parking:Parking = ParkingFactory.getParkingFromJson(value.object as! [String : AnyObject]);
                    self.annotationsParking.append(parking);
                    if count < 10 {
                        self.parkings.append(parking);
                        count+=1;
                    }
                }
            }
            print("-- getParkings() -- \(self.annotationsParking.count)");
            DispatchQueue.main.async(execute: {
                self.clusteringManager.removeAll();
                self.clusteringManager.add(annotations: self.annotationsParking);
                self.placeTableView.reloadData();
                self.fbReloadData();
            })
        }
    }
    
    func getFuels(bottom: CLLocationCoordinate2D, top: CLLocationCoordinate2D,  center: CLLocationCoordinate2D) {
        self.geoService.fuels(min: bottom, max: top, center: center).responseJSON { (response) in
            let old:[FuelStation] = self.fuels;
            self.fuels.removeAll();
            if let result = response.result.value {
                let jsonResult = JSON(result);
                for value in jsonResult["result"].array! {
                    let station:FuelStation = FuelStationFactory.getFuelStationFromJson(value);
                    self.fuels.append(station);
                }
            }
            print("-- getFuels() -- \(self.fuels.count)");
            DispatchQueue.main.async(execute: {
                self.placeMapView.removeAnnotations(old);
                self.placeMapView.addAnnotations(self.fuels);
            })
        }
    }
    
    func initMapView() {
        coreLocationInit()
        self.placeMapView.delegate = self
        self.placeMapView.showsUserLocation = true
        self.placeMapView.mapType = MKMapType(rawValue: 0)!
        self.placeMapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        
        /*let template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png";
        self.mapViewTemplate(template);*/
    }
    
    func updateMapView() {
        if hasFinishRendering {
            let bounds = self.placeMapView.getBoundingBox();
            let top = bounds[0];
            let bottom = bounds[1];
            let userLoc = self.placeMapView.userLocation;
            
            if self.parkingBtn.isSelected {
                self.getParkings(bottom: bottom, top: top, center: userLoc.coordinate);
            }
            else {
                self.annotationsParking.removeAll();
                self.parkings.removeAll();
                self.clusteringManager.removeAll();
                self.placeTableView.reloadData();
                self.fbReloadData();
            }
            
            if self.fuelBtn.isSelected {
                self.getFuels(bottom: bottom, top: top, center: userLoc.coordinate);
            }
            else {
                //TODO: self.placeMapView.removeAnnotations(annotationsFuel);
            }
            
            if self.electricBtn.isSelected {
                //TODO: self.getElectrics(bottom: bottom, top: top, center: userLoc.coordinate);
            }
            else {
                //TODO: self.placeMapView.removeAnnotations(annotationsElectric);
            }
            
            if self.accidentBtn.isSelected {
                //TODO: self.getAccidents(bottom: bottom, top: top, center: userLoc.coordinate);
            }
            else {
                //TODO: self.placeMapView.removeAnnotations(annotationsAccident);
            }
        }
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
        updateMapView();
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
        return self.parkings.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PlaceTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellId) as! PlaceTableViewCell;
        
        let place = self.parkings[indexPath.row];
        cell.setPlace(place);
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = self.parkings[indexPath.row];
        self.zoomOnMap(place.coordinate, meters: 3);
        self.alertForParking(place);
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
    
}

extension MapViewController: UISearchBarDelegate {
    
    func initSearchBar() {
        self.placeSearchBar.delegate = self;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text:String = searchBar.text {
            self.findAddress(text);
        } else {
            print("Nothing");
        }
    }
    
}

