//
//  Location.swift
//  Summon
//
//  Created by Owen Vnek on 1/19/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import MapKit

public class Location {
    
    private var placemark: MKPlacemark
    private var name: String?
    
    init(name: String?, placemark: MKPlacemark) {
        self.name = name
        self.placemark = placemark
    }
    
    func get_name() -> String? {
        return name
    }
    
    func get_placemark() -> MKPlacemark {
        return placemark
    }
    
}
