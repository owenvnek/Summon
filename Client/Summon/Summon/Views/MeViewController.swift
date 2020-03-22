//
//  MeViewController.swift
//  Summon
//
//  Created by Owen Vnek on 1/27/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import UIKit
import SocketIO

class MeViewController: UITableViewController {
    
    private var list: [String] = [
        "Profile",
        "Change Password",
        "Logout"
    ]
    
    override func viewDidLoad() {
        let call_back_logged_out: NormalCallback = { dataArray, ack in
            self.logged_out()
        }
        SocketIOManager.sharedInstance.listen(event_name: "logged_out", call_back: call_back_logged_out)
        tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = list[indexPath.row]
        cell.textLabel?.font = UIFont(name: SummonUserContext.font_name, size: (cell.textLabel?.font!.pointSize)!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: performSegue(withIdentifier: "show_profile", sender: self)
        case 1: performSegue(withIdentifier: "show_change_password", sender: self)
        case 2: logout()
        default: break
        }
    }
    
    func logout() {
        delete_login_details()
        SocketIOManager.sharedInstance.send(event_name: "logout", items: [
            "username": SummonUserContext.me!.get_username()
        ])
    }
    
    func logged_out() {
        self.performSegue(withIdentifier: "logged_out", sender: self)
    }
    
    func delete_login_details() {
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "password")
    }
    
}
