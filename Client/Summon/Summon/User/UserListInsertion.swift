//
//  UserListInsertion.swift
//  Summon
//
//  Created by Owen Vnek on 2/5/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import Foundation

class UserListInsertion {
    
    private var user_selection_view_controller: UserSelectionViewController
    private var insertion_queue: DispatchQueue
    
    init(user_selection_view_controller: UserSelectionViewController) {
        self.user_selection_view_controller = user_selection_view_controller
        insertion_queue = DispatchQueue(label: "insertion_queue", qos: .default, attributes: .concurrent, autoreleaseFrequency: .never, target: .none)
    }
    
    func get_users() -> [User] {
        return user_selection_view_controller.get_users()
    }
    
    func insert(user: User) {
        user_selection_view_controller.insert(user: user)
    }
    
    func insert(selected_row: Int) {
        user_selection_view_controller.insert(selected_row: selected_row)
    }
    
    func add(data: NSArray) {
        insertion_queue.async {
            for object in data {
                if let friend = object as? NSDictionary {
                    let user = User.from(data: friend)
                    self.insert(user: user)
                    self.user_selection_view_controller.data_updated()
                } else {
                    print("ERROR: Invalid friend data")
                }
            }
        }
    }
    
    func add(user: User) {
        insert(user: user)
        user_selection_view_controller.data_updated()
    }
    
    func add_selected(user: User) {
        let indexPath = IndexPath(row: get_users().count, section: 0)
        insert(user: user)
        insert(selected_row: get_users().count - 1)
        user_selection_view_controller.data_updated()
        user_selection_view_controller.add_check_mark(indexPath: indexPath.row)
        user_selection_view_controller.data_updated()
    }
    
}
