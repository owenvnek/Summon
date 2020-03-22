//
//  UserCellSelection.swift
//  Summon
//
//  Created by Owen Vnek on 2/5/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import Foundation

class UserSelection {
    
    private var user_selection_view_controller: UserSelectionViewController
    
    init(user_selection_view_controller: UserSelectionViewController) {
        self.user_selection_view_controller = user_selection_view_controller
    }
    
    func get_users() -> [User] {
        return user_selection_view_controller.get_users()
    }
    
    func does_allow_multi_selection() -> Bool {
        return user_selection_view_controller.does_allow_multi_selection()
    }
    
    func get_selected_rows() -> Set<Int> {
        return user_selection_view_controller.get_selected_rows()
    }
    
    func get_call_back() -> ((String) -> (Void))? {
        return user_selection_view_controller.get_call_back()
    }
    
    func set(selected_user: User) {
        user_selection_view_controller.set(selected_user: selected_user)
    }
    
    func insert(selected_row: Int) {
        user_selection_view_controller.insert(selected_row: selected_row)
    }
    
    func remove(selected_row: Int) {
        user_selection_view_controller.remove(selected_row: selected_row)
    }
    
    func cell_selected(index: Int) {
        set(selected_user:user_selection_view_controller.get_users()[index])
        if does_allow_multi_selection() {
            if !get_selected_rows().contains(index) {
                insert(selected_row: index)
                user_selection_view_controller.add_check_mark(indexPath: index)
            } else {
                remove(selected_row: index)
                user_selection_view_controller.remove_check_mark(indexPath: index)
            }
        } else {
            let user = get_users()[index]
            let username = user.get_username()
            if get_call_back() != nil {
                get_call_back()!(username)
            }
        }
    }
    
    func get_selected_users() -> [User] {
        var result: [User] = []
        for index in get_selected_rows() {
            let user = get_users()[index]
            result.append(user)
        }
        return result
    }
    
}
