//
//  SummonListViewController.swift
//  Summon
//
//  Created by Owen Vnek on 1/3/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import UIKit

class SummonListViewController: UITableViewController {
    
    private var summons: [Summon]!
    private var selected_summon: Summon!
    private var summon_list_mode: SummonListMode!
    private var summon_cell_creation: SummonCellCreation!
    private var summon_detail: SummonDetail!
    private var summon_list_insertion: SummonListInsertion!
    private var empty: Bool!
    private var empty_message: String!
    
    private static let sections: Int = 1
    private static let row_height: CGFloat = 95
    
    override func viewDidLoad() {
        summon_cell_creation = SummonCellCreation(summon_list_view_controller: self)
        summon_detail = SummonDetail(summon_list_view_controller: self)
        summon_list_insertion = SummonListInsertion(summon_list_view_controller: self)
        if summons == nil {
            summons = []
        }
        empty = true
        AppearanceConfig.shared.summon_list(table_view: tableView)
    }
    
    func get_summons() -> [Summon] {
        return summons
    }
    
    func get_selected_summon() -> Summon {
        return selected_summon
    }
    
    func get_summon_list_mode() -> SummonListMode {
        return summon_list_mode
    }
    
    func set(summons: [Summon]) {
        self.summons = summons
    }
    
    func set(selected_summon: Summon) {
        self.selected_summon = selected_summon
    }
    
    func set(summon_list_mode: SummonListMode) {
        self.summon_list_mode = summon_list_mode
    }
    
    func set(empty_message: String) {
        self.empty_message = empty_message
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return SummonListViewController.sections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if empty {
            return 1
        }
        return summons.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !empty {
            let index = indexPath.row
            selected_summon = summons[index]
            performSegue(withIdentifier: "summon_detail", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if empty {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SummonListViewController.row_height
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if empty {
            return summon_cell_creation.create_empty_cell(empty_message: empty_message)
        }
        return summon_cell_creation.create_cell(indexPath: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SummonDetailViewController {
            summon_detail.update(destination: destination)
        }
    }
    
    func add_to_back(summon: Summon) {
        summon_list_insertion.add_to_back(summon: summon)
    }
    
    func add_to_front(summon: Summon) {
        summon_list_insertion.add_to_front(summon: summon)
    }

    func add_to_back(data: NSArray) {
        summon_list_insertion.add_to_back(data: data)
    }
    
    func add_to_front(data: NSArray) {
        summon_list_insertion.add_to_front(data: data)
    }
    
    func reset() {
        summons = []
    }
    
    func delete_summon(id: Int) {
        summon_list_insertion.delete_summon(id: id)
    }
    
    func data_updated() {
        tableView.reloadData()
        empty = summons.count == 0
    }
    
    func dequeue_cell() -> SummonCellView? {
        return tableView.dequeueReusableCell(withIdentifier: "cell") as? SummonCellView
    }
    
    func dequeue_empty_cell() -> UITableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: "empty_cell")
    }
    
}
