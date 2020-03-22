//
//  SummonTabbarController.swift
//  Summon
//
//  Created by Owen Vnek on 1/7/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import UIKit

class SummonTabbarController: UITabBarController {
    
    override func viewDidLoad() {
        UITabBar.appearance().barTintColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        UITabBar.appearance().tintColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        UITabBar.appearance().isTranslucent = false
        SummonUserContext.tabbar_controller = self
    }
    
}
