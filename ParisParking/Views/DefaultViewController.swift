//
//  DefaultViewController.swift
//  ParisParking
//
//  Created by Nicolas Fonsat on 29/11/2016.
//  Copyright © 2016 Nicolas Fonsat. All rights reserved.
//

import UIKit

class DefaultViewController: UIViewController {
    
    var backTitle: String {
        get {
            return "";
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigation = self.navigationController {
            navigation.navigationBar.isTranslucent = false;
            
            
            if let topItem = navigation.navigationBar.topItem {
                let backButton: UIBarButtonItem = UIBarButtonItem();
                backButton.title = backTitle;
                topItem.backBarButtonItem = backButton;
            }
        }
    }

}
