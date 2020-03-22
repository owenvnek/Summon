//
//  UserCellViewController.swift
//  Summon
//
//  Created by Owen Vnek on 12/23/19.
//  Copyright © 2019 Nio. All rights reserved.
//

import UIKit

class UserCellView: UITableViewCell {
    
    private var status_level: Int!
    @IBOutlet weak var name_label: UILabel!
    @IBOutlet weak var profile_image: UIImageView!
    
    func set_name_label(name: String) {
        name_label.text = name
        name_label.font = UIFont(name: SummonUserContext.font_name, size: name_label.font!.pointSize)
        name_label.textColor = User.color_for(status_level: status_level)
    }
    
    func set_profile_image(image: UIImage) {
        profile_image.image = image
        profile_image.layer.cornerRadius = profile_image.frame.height / 2
        profile_image.layer.masksToBounds = true
    }
    
    func input(status_level: Int) {
        self.status_level = status_level
    }
    
}
