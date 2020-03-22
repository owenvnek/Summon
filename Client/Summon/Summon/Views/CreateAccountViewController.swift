//
//  CreateAccountViewController.swift
//  Summon
//
//  Created by Owen Vnek on 12/24/19.
//  Copyright © 2019 Nio. All rights reserved.
//

import UIKit
import SocketIO

class CreateAccountViewController: UIViewController {
    
    private var account_creation: AccountCreation!
    @IBOutlet weak var create_account_label: UILabel!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var repeat_password: UITextField!
    @IBOutlet weak var submit_button: UIButton!
    
    override func viewDidLoad() {
        account_creation = AccountCreation(create_account_view_controller: self)
        account_creation.create_listeners()
        AppearanceConfig.shared.create_account(create_account_view_controller: self)
    }
    
    func get_username() -> String {
        return username.text!
    }
    
    func get_name() -> String {
        return name.text!
    }
    
    func get_password() -> String {
        return password.text!
    }
    
    func get_repeat_password() -> String {
        return repeat_password.text!
    }
    
    @IBAction func submit_button_pressed(_ sender: Any) {
        account_creation.create_account()
    }
    
}
