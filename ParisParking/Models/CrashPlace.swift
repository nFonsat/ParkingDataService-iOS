//
//  CrashPlace.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 30/11/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import UIKit

class CrashPlace: Place {
    var creation:Date?
    
    override var image: String {
        get {
            return "crash-locate"
        }
        set {}
    }
    
}
