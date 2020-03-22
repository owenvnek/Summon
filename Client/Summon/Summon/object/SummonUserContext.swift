//
//  SummonUserContext.swift
//  Summon
//
//  Created by Owen Vnek on 12/23/19.
//  Copyright © 2019 Nio. All rights reserved.
//

import Foundation
import UIKit

class SummonUserContext {
    
    static let version: Double = 1.2
    static var me: User?
    static var device_token: String? = nil
    static var storyboard: UIStoryboard!
    static var tabbar_controller: UITabBarController?
    static let font_name: String = "AppleSDGothicNeo-Medium"
    static let bold_font_name: String = "AppleSDGothicNeo-Bold"
    private static var request_id: Int = 0
    
    static func get_request_id() -> Int {
        SummonUserContext.request_id += 1
        return request_id
    }
    
    static func login(username: String, password: String) {
        var data = [
            "username": username,
            "password": password,
            "device_token": SummonUserContext.device_token
        ]
        if SummonUserContext.device_token != nil {
            data["device_token"] = SummonUserContext.device_token!
            print("Logging in with device token \(SummonUserContext.device_token!)")
        }
        SocketIOManager.sharedInstance.send(event_name: "login", items: data)
    }
    
}
