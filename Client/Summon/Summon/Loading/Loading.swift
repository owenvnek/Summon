//
//  Loading.swift
//  Summon
//
//  Created by Owen Vnek on 2/4/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import Foundation
import SocketIO

class Loading {
    
    private var loading_view_controller: LoadingViewController
    
    init(loading_view_controller: LoadingViewController) {
        self.loading_view_controller = loading_view_controller
    }
    
    func check_warning() {
        /**
        if !loading_view_controller.isWarningAcknowledged() {
            loading_view_controller.show_warning()
            return
        }
          */
        if SocketIOManager.sharedInstance.did_connect() {
            try_auto_login()
        }
    }
    
    func check_acknowledgment() {
        /**
        if let warning_acknowledged = UserDefaults.standard.value(forKey: "warning_acknowledged") as? Bool {
            loading_view_controller.set(warning_acknowledged: warning_acknowledged)
         } else {
            loading_view_controller.set(warning_acknowledged: false)
         }
         */
    }
    
    func create_listeners() {
        let call_back_version_check: NormalCallback = { dataArray, ack in
            self.version_check()
        }
        let call_back_version_verification_failed: NormalCallback = { dataArray, ack in
            self.version_verification_failed()
        }
        let call_back_connected: NormalCallback = { dataArray, ack in
            self.try_auto_login()
        }
        let call_back_connection_failed: NormalCallback = { dataArray, ack in
            self.connection_failed()
        }
        let call_back_login_successful: NormalCallback = { dataArray, ack in
            self.login_successful(dataArray: dataArray)
        }
        let call_back_login_failed: NormalCallback = { dataArray, ack in
            self.auto_login_failed()
        }
        SocketIOManager.sharedInstance.listen(event_name: "version_check", call_back: call_back_version_check)
        SocketIOManager.sharedInstance.listen(event_name: "version_verified", call_back: call_back_connected)
        SocketIOManager.sharedInstance.listen(event_name: "version_verification_failed", call_back: call_back_version_verification_failed)
        SocketIOManager.sharedInstance.listen(event_name: "error", call_back: call_back_connection_failed)
        SocketIOManager.sharedInstance.listen(event_name: "login_successful", call_back: call_back_login_successful)
        SocketIOManager.sharedInstance.listen(event_name: "login_failed", call_back: call_back_login_failed)
    }
    
    func version_check() {
        let data: [String: Any] = [
            "version": SummonUserContext.version
        ]
        SocketIOManager.sharedInstance.send(event_name: "version_send", items: data)
    }
    
    func version_verification_failed() {
        loading_view_controller.status_label.text = "You are using an outdated version of Summon"
    }
    
    func try_auto_login() {
        if loading_view_controller.didTryLoggingIn() {
            return
        }
        if let username = UserDefaults.standard.value(forKey: "username") as? String {
            if let password = UserDefaults.standard.value(forKey: "password") as? String {
                SummonUserContext.login(username: username, password: password)
            } else {
                auto_login_failed()
            }
        } else {
            auto_login_failed()
        }
        loading_view_controller.set(tried_logging_in: true)
    }
    
    func connection_failed() {
        loading_view_controller.status_label.text = "Failed to connect to Summon servers"
    }
    
    func auto_login_failed() {
        delete_login_details()
        loading_view_controller.performSegue(withIdentifier: "done_loading", sender: self)
    }
    
    func delete_login_details() {
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "password")
    }
    
    func login_successful(dataArray: [Any]) {
        try_auto_login()
        extract_login_data(dataArray: dataArray)
        loading_view_controller.login_successful()
    }
    
    func extract_login_data(dataArray: [Any]) {
        if let typeDict = dataArray[0] as? NSArray {
            if let inner_data = typeDict[0] as? NSDictionary {
                SummonUserContext.me = User.from(data: inner_data)
            }
        }
    }
    
}
