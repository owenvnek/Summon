//
//  SummonNavigationController.swift
//  Summon
//
//  Created by Owen Vnek on 1/7/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import UIKit

class SummonNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        UINavigationBar.appearance().tintColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),NSAttributedString.Key.font: UIFont(name: SummonUserContext.bold_font_name, size: 25)!]
    }
    
}
