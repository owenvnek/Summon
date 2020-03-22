//
//  User.swift
//  Summon
//
//  Created by Owen Vnek on 12/23/19.
//  Copyright © 2019 Nio. All rights reserved.
//

import UIKit

class User {
    
    private var username: String
    private var name: String
    private var image: UIImage
    private var friend: Bool
    private var status_level: Int
    private var status_message: String?
    private var join_date: DateTime
    
    init(username: String) {
        self.username = username
        self.name = ""
        self.image = UIImage()
        friend = false
        status_level = 0
        status_message = nil
        join_date = DateTime()
    }
    
    func get_username() -> String {
        return username
    }
    
    func get_name() -> String {
        return name
    }
    
    func get_image() -> UIImage {
        return image
    }
    
    func is_friend() -> Bool {
        return friend
    }
    
    func get_status_message() -> String? {
        return status_message
    }
    
    func get_status_level() -> Int {
        return status_level
    }
    
    func get_join_date() -> DateTime {
        return join_date
    }
    
    func set(name: String) {
        self.name = name
    }
    
    func set(image: UIImage) {
        self.image = image
    }
    
    func set(status_message: String) {
        self.status_message = status_message
    }
    
    func set(status_level: Int) {
        self.status_level = status_level
    }
    
    func set(join_date: DateTime) {
        self.join_date = join_date
    }
    
    func mark_friend() {
        friend = true
    }
    
    func unmark_friend() {
        friend = false
    }
    
    static func color_for(status_level: Int) -> UIColor {
        if status_level == 1 {
            return #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        } else if status_level == 2 {
            return #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        } else if status_level == 3 {
            return #colorLiteral(red: 0.7450980544, green: 0.09671066433, blue: 0.2383271286, alpha: 1)
        }
        return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    static func from(data: NSDictionary) -> User {
        let username = data["username"] as! String
        let user = User(username: username)
        let status_level = data["status_level"] as! Int
        let join_date_data = data["join_date"] as! NSDictionary
        let join_date = DateTime.from(data: join_date_data)
        user.set(status_level: status_level)
        user.set(join_date: join_date)
        if !(data["name"] is NSNull) {
            let name = data["name"] as! String
            user.set(name: name)
        }
        if !(data["image"] is NSNull) {
            let image_data = data["image"] as! NSDictionary
            let inner_image_data = image_data["data"] as! [UInt8]
            let data_object = Data(bytes: inner_image_data, count: inner_image_data.count)
            let image = UIImage(data: data_object)
            user.set(image: image!)
        }
        if !(data.value(forKey: "status_message") == nil) {
            let status_message = data["status_message"] as! NSString
            user.set(status_message: status_message as String)
        }
        return user
    }
    
}
