//
//  WarningViewController.swift
//  Summon
//
//  Created by Owen Vnek on 1/27/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import UIKit

class WarningViewController: UIViewController {
    
    @IBOutlet weak var warning_label: UILabel!
    @IBOutlet weak var text: UITextView!
    @IBOutlet weak var understood_button: UIButton!
    @IBOutlet weak var signature_label: UILabel!
    
    override func viewDidLoad() {
        warning_label.font = UIFont(name: SummonUserContext.bold_font_name, size: warning_label.font!.pointSize)
        text.font = UIFont(name: SummonUserContext.font_name, size: text.font!.pointSize)
        understood_button.titleLabel!.font = UIFont(name: SummonUserContext.bold_font_name, size: understood_button.titleLabel!.font!.pointSize)
        signature_label.font = UIFont(name: SummonUserContext.bold_font_name, size: signature_label.font!.pointSize)
    }
    
    @IBAction func understood_button_pressed(_ sender: Any) {
        UserDefaults.standard.setValue(true, forKey: "warning_acknowledged")
        performSegue(withIdentifier: "go_back", sender: self)
    }
    
}
