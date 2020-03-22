//
//  Summon.swift
//  Summon
//
//  Created by Owen Vnek on 1/3/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class Summon {
    
    private var owner: User
    private var title: String
    private var participants: [User]
    private var datetime: DateTime
    private var id: Int
    private var location: Location?
    
    init() {
        owner = User(username: "")
        title = ""
        participants = []
        datetime = DateTime()
        id = 0
        location = nil
    }
    
    func get_owner() -> User {
        return owner
    }
    
    func get_title() -> String {
        return title
    }
    
    func get_participants() -> [User] {
        return participants
    }
    
    func get_datetime() -> DateTime {
        return datetime
    }
    
    func get_id() -> Int {
        return id
    }
    
    func get_location() -> Location? {
        return location
    }
    
    func set(owner: User) {
        self.owner = owner
    }
    
    func set(title: String) {
        self.title = title
    }
    
    func set(participants: [User]) {
        self.participants = participants
    }
    
    func add(participant: User) {
        self.participants.append(participant)
    }
    
    func set(datetime: DateTime) {
        self.datetime = datetime
    }
    
    func set(id: Int) {
        self.id = id
    }
    
    func set(location: Location) {
        self.location = location
    }
    
    static func from(data: NSDictionary) -> Summon {
        let owner = data["owner"] as! NSDictionary
        let title = data["title"] as! String
        let id = data["id"] as! Int
        let participants = data["participants"] as! NSArray
        let datetime_data = data["datetime"] as! NSDictionary
        let summon = Summon()
        summon.set(owner: User.from(data: owner))
        summon.set(title: title)
        summon.set(id: id)
        if let location_data = data["location"] as? NSDictionary {
            let name = location_data["name"] as? String
            let latitude = location_data["latitude"] as! Double
            let longitude = location_data["longitude"] as! Double
            let street = location_data["street"] as? String
            let city = location_data["city"] as? String
            let state = location_data["state"] as? String
            let postalCode = location_data["postalCode"] as? String
            let country = location_data["country"] as? String
            let isoCountryCode = location_data["isoCountryCode"] as? String
            let subAdministrativeArea = location_data["subAdministrativeArea"] as? String
            let subLocality = location_data["subLocality"] as? String
            let postal_address = CNMutablePostalAddress()
            if street != nil {
                postal_address.street = street!
            }
            if city != nil {
                postal_address.city = city!
            }
            if state != nil {
                postal_address.state = state!
            }
            if postalCode != nil {
                postal_address.postalCode = postalCode!
            }
            if country != nil {
                postal_address.country = country!
            }
            if isoCountryCode != nil {
                postal_address.isoCountryCode = isoCountryCode!
            }
            if subAdministrativeArea != nil {
                postal_address.subAdministrativeArea = subAdministrativeArea!
            }
            if subLocality != nil {
                postal_address.subLocality = subLocality!
            }
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let placemark = MKPlacemark(coordinate: coordinates, postalAddress: postal_address)
            let location = Location(name: name, placemark: placemark)
            summon.set(location: location)
        }
        for participant in participants {
            if !(participant is NSNull) {
                let user = User.from(data: participant as! NSDictionary)
                summon.add(participant: user)
            }
        }
        summon.set(datetime: DateTime.from(data: datetime_data))
        return summon
    }
    
}
