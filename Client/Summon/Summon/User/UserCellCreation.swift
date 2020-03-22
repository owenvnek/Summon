//
//  UserCellCreation.swift
//  Summon
//
//  Created by Owen Vnek on 2/5/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import Foundation

class UserCellCreation {
    
    private var user_selection_view_controller: UserSelectionViewController
    
    init(user_selection_view_controller: UserSelectionViewController) {
        self.user_selection_view_controller = user_selection_view_controller
    }
    
    func get_users() -> [User] {
        return user_selection_view_controller.get_users()
    }
    
    func create_cell(index: Int) -> UserCellView {
        if let cell = user_selection_view_controller.dequeue_cell() {
            let user = get_users()[index]
            let name = user.get_name()
            let image = user.get_image()
            let status_level = user.get_status_level()
            cell.input(status_level: status_level)
            cell.set_name_label(name: name)
            cell.set_profile_image(image: image)
            cell.selectionStyle = .none
            return cell
        }
        fatalError("Failed to create cell")
    }
    
}
