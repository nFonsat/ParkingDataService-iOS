//
//  MKMapViewExt.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 07/11/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import UIKit
import MapKit


extension MKMapView {
    
    func getNECoordinate() -> CLLocationCoordinate2D {
        let rect:MKMapRect = self.visibleMapRect;
        return self.getCoordinateFromMapRectanglePoint(x: MKMapRectGetMaxX(rect), y: rect.origin.y);
    }
    
    func getNWCoordinate() -> CLLocationCoordinate2D {
        let rect:MKMapRect = self.visibleMapRect;
        return self.getCoordinateFromMapRectanglePoint(x: MKMapRectGetMinX(rect), y: rect.origin.y);
    }
    
    func getSECoordinate() -> CLLocationCoordinate2D {
        let rect:MKMapRect = self.visibleMapRect;
        return self.getCoordinateFromMapRectanglePoint(x: MKMapRectGetMaxX(rect), y: MKMapRectGetMaxY(rect));
    }
    
    func getSWCoordinate() -> CLLocationCoordinate2D {
        let rect:MKMapRect = self.visibleMapRect;
        return self.getCoordinateFromMapRectanglePoint(x: rect.origin.x, y: MKMapRectGetMaxY(rect));
    }
    
    func getCoordinateFromMapRectanglePoint(x:Double, y:Double) -> CLLocationCoordinate2D {
        let swMapPoint:MKMapPoint = MKMapPointMake(x, y);
        return MKCoordinateForMapPoint(swMapPoint);
    }
    
    func getBoundingBox() -> [CLLocationCoordinate2D] {
        let bottomLeft:CLLocationCoordinate2D = self.getSWCoordinate();
        let topRight:CLLocationCoordinate2D   = self.getNECoordinate();
        return [bottomLeft, topRight];
    }
}
