//
//  UserSelectionViewController.swift
//  Summon
//
//  Created by Owen Vnek on 12/23/19.
//  Copyright © 2019 Nio. All rights reserved.
//

import UIKit

class UserSelectionViewController: UITableViewController {
    
    private var user_selection: UserSelection!
    private var user_cell_creation: UserCellCreation!
    private var user_list_insertion: UserListInsertion!
    private var users: [User] = []
    private var selected_user: User!
    private var call_back: ((String) -> Void)!
    private var allow_multi_selection: Bool!
    private var selected_rows: Set<Int>!
    private var data_received: Bool!
    
    private static let sections: Int = 1
    private static let row_height: CGFloat = 53
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user_selection = UserSelection(user_selection_view_controller: self)
        user_cell_creation = UserCellCreation(user_selection_view_controller: self)
        user_list_insertion = UserListInsertion(user_selection_view_controller: self)
        if allow_multi_selection == nil {
            allow_multi_selection = false
        }
        selected_rows = Set<Int>()
        tableView.separatorColor = UIColor.clear
        if data_received == nil {
            data_received = false
        }
    }
    
    func get_users() -> [User] {
        return users
    }
    
    func get_selected_users() -> [User] {
        return user_selection.get_selected_users()
    }
    
    func does_allow_multi_selection() -> Bool {
        return allow_multi_selection
    }
    
    func get_selected_rows() -> Set<Int> {
        return selected_rows
    }
    
    func get_call_back() -> ((String) -> (Void))? {
        return call_back
    }
    
    func set(selected_user: User) {
        self.selected_user = selected_user
    }
    
    func insert(selected_row: Int) {
        selected_rows.insert(selected_row)
    }
    
    func remove(selected_row: Int) {
        selected_rows.remove(selected_row)
    }
    
    func set(call_back: @escaping (String) -> Void) {
        self.call_back = call_back
    }
    
    func enable_multi_selection() {
        allow_multi_selection = true
    }
    
    func add(data: NSArray) {
        user_list_insertion.add(data: data)
    }
    
    func add(user: User) {
        //user_list_insertion.add(user: user)
        users.append(user)
        data_updated()
    }
    
    func mark_data_received() {
        data_received = true
    }
    
    func remove_user_with(username: String) {
        if users.count > 0 {
            var users_copy = users
            for i in stride(from: users.count - 1, to: 0, by: -1) {
                let user = users[i]
                if user.get_username() == username {
                    users_copy.remove(at: i)
                }
            }
            users = users_copy
            tableView.reloadData()
        }
    }
    
    func add_selected(user: User) {
        user_list_insertion.add_selected(user: user)
    }
    
    func insert(user: User) {
        users.append(user)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return UserSelectionViewController.sections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data_received {
            return users.count
        } else {
            return users.count + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        if index < users.count {
            return user_selection.cell_selected(index: index)
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let index = indexPath.row
        if index < users.count {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UserSelectionViewController.row_height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        if index == users.count {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "loading_cell")
            let spinny_symbol = UIActivityIndicatorView(style: .medium)
            cell.addSubview(spinny_symbol)
            spinny_symbol.startAnimating()
            spinny_symbol.frame = CGRect(origin: CGPoint(x: view.frame.width / 2 - spinny_symbol.frame.width / 2, y: 0), size: CGSize(width: 50, height: 50))
            return cell
        } else {
            return user_cell_creation.create_cell(index: index)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AccountDetailViewController {
            destination.set(user: selected_user)
            destination.set(friend_list: self)
        }
    }
    
    func dequeue_cell() -> UserCellView? {
        return tableView.dequeueReusableCell(withIdentifier: "cell") as? UserCellView
    }
    
    func show_detail() {
        performSegue(withIdentifier: "account_detail", sender: self)
    }
    
    func reset() {
        users = []
        data_updated()
    }
    
    func data_updated() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func data_updated_direct() {
        self.tableView.reloadData()
    }
    
    func add_check_mark(indexPath: Int) {
        tableView.cellForRow(at: IndexPath(row: indexPath, section: 0))?.accessoryType = .checkmark
    }
    
    func remove_check_mark(indexPath: Int) {
        tableView.cellForRow(at: IndexPath(row: indexPath, section: 0))?.accessoryType = .none
    }
    
}
