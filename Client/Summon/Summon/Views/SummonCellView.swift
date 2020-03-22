//
//  SummonCellView.swift
//  Summon
//
//  Created by Owen Vnek on 1/3/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import UIKit

class SummonCellView: UITableViewCell {
    
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var owner_label: UILabel!
    @IBOutlet weak var participants_label: UILabel!
    @IBOutlet weak var datetime_label: UILabel!
    @IBOutlet weak var profile_image: UIImageView!
    
    func set(owner: String) {
        owner_label.text = owner
        owner_label.font = UIFont(name: SummonUserContext.bold_font_name, size: owner_label.font!.pointSize)
    }
    
    func set(title: String) {
        title_label.text = title
        title_label.font = UIFont(name: SummonUserContext.font_name, size: title_label.font!.pointSize)
    }
    
    func set(participants: String) {
        participants_label.text = participants
        participants_label.font = UIFont(name: SummonUserContext.font_name, size: participants_label.font!.pointSize)
    }
    
    func set(datetime: String) {
        datetime_label.text = datetime
        datetime_label.font = UIFont(name: SummonUserContext.font_name, size: datetime_label.font!.pointSize)
    }
    
    func set(image: UIImage) {
        profile_image.image = image
        profile_image.layer.cornerRadius = profile_image.frame.height / 2
        profile_image.layer.masksToBounds = true
    }
    
}
