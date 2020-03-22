//
//  ChangePasswordViewController.swift
//  Summon
//
//  Created by Owen Vnek on 1/27/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import UIKit
import SocketIO

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var submit_button: UIButton!
    @IBOutlet weak var current_password_textfield: UITextField!
    @IBOutlet weak var new_password_textfield: UITextField!
    @IBOutlet weak var repeat_new_password_textfield: UITextField!
    
    override func viewDidLoad() {
        let call_back_password_changed: NormalCallback = { dataArray, ack in
            self.password_changed()
        }
        let call_back_failed_to_change_password: NormalCallback = { dataArray, ack in
            self.failed_to_change_password(data: dataArray)
        }
        SocketIOManager.sharedInstance.listen(event_name: "password_changed", call_back: call_back_password_changed)
        SocketIOManager.sharedInstance.listen(event_name: "failed_to_change_password", call_back: call_back_failed_to_change_password)
        current_password_textfield.font = UIFont(name: SummonUserContext.font_name, size: current_password_textfield.font!.pointSize)
        new_password_textfield.font = UIFont(name: SummonUserContext.font_name, size: new_password_textfield.font!.pointSize)
        repeat_new_password_textfield.font = UIFont(name: SummonUserContext.font_name, size: repeat_new_password_textfield.font!.pointSize)
        submit_button.titleLabel!.font = UIFont(name: SummonUserContext.font_name, size: submit_button.titleLabel!.font!.pointSize)
        current_password_textfield.setBottomBorder()
        new_password_textfield.setBottomBorder()
        repeat_new_password_textfield.setBottomBorder()
    }
    
    @IBAction func submit_button_pressed(_ sender: Any) {
        if new_password_textfield.text! != repeat_new_password_textfield.text! {
            let alert = UIAlertController(title: "Invalid Password", message: "Password field must match repeat password field", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            SocketIOManager.sharedInstance.send(event_name: "change_password", items: [
                "username": SummonUserContext.me!.get_username(),
                "current_password": current_password_textfield.text!,
                "new_password": new_password_textfield.text!
            ])
        }
    }
    
    func failed_to_change_password(data: [Any]) {
        if let reason_data = data[0] as? NSDictionary {
            if let reason = reason_data["reason"] as? String {
                let alert = UIAlertController(title: "Failed to Change Password", message: reason, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func password_changed() {
        let alert = UIAlertController(title: "Password Changed", message: "Successfully changed your password", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
            alert in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
}
