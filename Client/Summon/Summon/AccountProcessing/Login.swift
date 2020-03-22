//
//  Login.swift
//  Summon
//
//  Created by Owen Vnek on 2/4/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import Foundation
import SocketIO

class Login {
    
    private var login_view_controller: LoginViewController
    
    init(login_view_controller: LoginViewController) {
        self.login_view_controller = login_view_controller
    }
    
    private var username: String {
        get {
            return login_view_controller.get_username()
        }
    }
    
    private var password: String {
        get {
            return login_view_controller.get_password()
        }
    }
    
    func create_listeners() {
        let call_back_login_successful: NormalCallback = { dataArray, ack in
            self.login_successful(dataArray: dataArray)
        }
        let call_back_login_failed: NormalCallback = { dataArray, ack in
            self.login_failed(dataArray: dataArray)
        }
        SocketIOManager.sharedInstance.listen(event_name: "login_successful", call_back: call_back_login_successful)
        SocketIOManager.sharedInstance.listen(event_name: "login_failed", call_back: call_back_login_failed)
    }
    
    func login_successful(dataArray: [Any]) {
        if let typeDict = dataArray[0] as? NSArray {
            if let inner_data = typeDict[0] as? NSDictionary {
                SummonUserContext.me = User.from(data: inner_data)
            }
        }
        save_login_details()
        login_view_controller.performSegue(withIdentifier: "login_successful", sender: self)
    }
    
    func save_login_details() {
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(password, forKey: "password")
    }
    
    func login_failed(dataArray: [Any]) {
        if let typeDict = dataArray[0] as? NSDictionary {
            let reason = typeDict["reason"] as! String
            let alert = UIAlertController(title: "Login Failed", message: reason, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            login_view_controller.present(alert, animated: true, completion: nil)
        }
    }
    
}
