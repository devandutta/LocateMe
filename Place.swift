//
//  Place.swift
//  LocateMe
//
//  Created by Devan Dutta on 11/26/15.
//  Copyright © 2015 devan.dutta. All rights reserved.
//

import UIKit
import MapKit

class Place: NSObject, MKAnnotation {
    
    let title: String?
    let subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title:String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title=title
        self.subtitle=subtitle
        self.coordinate=coordinate
    }
}