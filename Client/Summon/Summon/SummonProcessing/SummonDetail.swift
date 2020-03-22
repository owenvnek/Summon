//
//  SummonDetail.swift
//  Summon
//
//  Created by Owen Vnek on 2/3/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import UIKit

class SummonDetail {
    
    private var summon_list_view_controller: SummonListViewController
    
    init(summon_list_view_controller: SummonListViewController) {
        self.summon_list_view_controller = summon_list_view_controller
    }
    
    func update(destination: SummonDetailViewController) {
        let selected_summon = summon_list_view_controller.get_selected_summon()
        destination.set(summon: selected_summon)
        destination.set(owner: selected_summon.get_owner())
        destination.set(title: selected_summon.get_title())
        destination.set(datetime: selected_summon.get_datetime().to_string())
        destination.set(location: selected_summon.get_location())
        destination.set(summon_list_view_controller: summon_list_view_controller)
        for participant in selected_summon.get_participants() {
            destination.add(participant: participant)
        }
    }
    
}
