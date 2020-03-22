//
//  LoginViewController.swift
//  Summon
//
//  Created by Owen Vnek on 12/22/19.
//  Copyright © 2019 Nio. All rights reserved.
//

import UIKit
import SocketIO

class LoginViewController: UIViewController {
    
    private var login: Login!
    @IBOutlet weak var username_field: UITextField!
    @IBOutlet weak var password_field: UITextField!
    @IBOutlet weak var login_label: UILabel!
    @IBOutlet weak var login_button: UIButton!
    @IBOutlet weak var create_account_button: UIButton!
    
    override func viewDidLoad() {
        login = Login(login_view_controller: self)
        login.create_listeners()
        AppearanceConfig.shared.login(login_view_controller: self)
    }
    
    func get_username() -> String {
        return username_field.text!
    }
    
    func get_password() -> String {
        return password_field.text!
    }
    
    @IBAction func login_button_pressed(_ sender: Any) {
        SummonUserContext.login(username: get_username(), password: get_password())
    }
    
}
