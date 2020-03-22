//
//  AccountCreation.swift
//  Summon
//
//  Created by Owen Vnek on 2/4/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import UIKit
import SocketIO

class AccountCreation {
    
    private var create_account_view_controller: CreateAccountViewController
    
    init(create_account_view_controller: CreateAccountViewController) {
        self.create_account_view_controller = create_account_view_controller
    }
    
    private var username: String {
        get {
            return create_account_view_controller.get_username()
        }
    }
    
    private var name: String {
        get {
            return create_account_view_controller.get_name()
        }
    }
    
    private var password: String {
        get {
            return create_account_view_controller.get_password()
        }
    }
    
    private var repeat_password: String {
        get {
            return create_account_view_controller.get_repeat_password()
        }
    }
    
    func create_listeners() {
        let call_back_account_creation_successful: NormalCallback = { dataArray, ack in
            self.account_creation_successful()
        }
        let call_back_account_creation_failed: NormalCallback = { dataArray, ack in
            self.account_creation_failed(dataArray: dataArray)
        }
        SocketIOManager.sharedInstance.listen(event_name: "account_creation_successful", call_back: call_back_account_creation_successful)
        SocketIOManager.sharedInstance.listen(event_name: "account_creation_failed", call_back: call_back_account_creation_failed)
    }
    
    func account_creation_successful() {
        let alert = UIAlertController(title: "Account Created", message: "Successfully created your account", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { alert in
            self.create_account_view_controller.performSegue(withIdentifier: "account_creation_successful", sender: self)
        }))
        create_account_view_controller.present(alert, animated: true, completion: nil)
    }
    
    func account_creation_failed(dataArray: [Any]) {
        if let typeDict = dataArray[0] as? NSDictionary {
            let reason = typeDict["reason"] as! String
            let alert = UIAlertController(title: "Failed to Create Account", message: reason, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            create_account_view_controller.present(alert, animated: true, completion: nil)
        }
    }
    
    func create_account() {
        if password == repeat_password {
            let data = [
                "username": username,
                "name": name,
                "password": password,
                "image": get_default_profile_image_data()
                ] as [String : Any]
            SocketIOManager.sharedInstance.send(event_name: "create_account", items: data)
        } else {
            let alert = UIAlertController(title: "Invalid Password", message: "Password field must match repeat password field", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            create_account_view_controller.present(alert, animated: true, completion: nil)
        }
    }
    
    private func get_default_profile_image_data() -> Data {
        let image = UIImage(named: "default_profile")
        return image!.jpegData(compressionQuality: 0.001)!
    }
    
}
