//
//  LoadingViewController.swift
//  Summon
//
//  Created by Owen Vnek on 12/23/19.
//  Copyright © 2019 Nio. All rights reserved.
//

import UIKit
import SocketIO

class LoadingViewController: UIViewController {
    
    private var warning_acknowledged: Bool!
    private var tried_logging_in: Bool!
    private var loading: Loading!
    @IBOutlet weak var activity_indicator: UIActivityIndicatorView!
    @IBOutlet weak var status_label: UILabel!
    @IBOutlet weak var summon_label: UILabel!

    override func viewDidLoad() {
        SummonUserContext.storyboard = storyboard
        tried_logging_in = false
        loading = Loading(loading_view_controller: self)
        loading.check_acknowledgment()
        loading.create_listeners()
        loading.check_warning()
        AppearanceConfig.shared.loading(loading_view_controller: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loading.check_warning()
    }
    
    func isWarningAcknowledged() -> Bool {
        return warning_acknowledged
    }
    
    func didTryLoggingIn() -> Bool {
        return tried_logging_in
    }
    
    func set(warning_acknowledged: Bool) {
        self.warning_acknowledged = warning_acknowledged
    }
    
    func set(tried_logging_in: Bool) {
        self.tried_logging_in = tried_logging_in
    }
    
    func show_warning() {
        performSegue(withIdentifier: "show_warning", sender: self)
    }
    
    func login_successful() {
        performSegue(withIdentifier: "login_successful", sender: self)
    }
    
}
