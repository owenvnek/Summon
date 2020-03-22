//
//  SummonListInsertion.swift
//  Summon
//
//  Created by Owen Vnek on 2/3/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import Foundation

class SummonListInsertion {
    
    private var summon_list_view_controller: SummonListViewController
    private var summon_sorting: SummonSorting
    private var insertion_queue: DispatchQueue
    
    init(summon_list_view_controller: SummonListViewController) {
        self.summon_list_view_controller = summon_list_view_controller
        summon_sorting = SummonSorting()
        insertion_queue = DispatchQueue(label: "summon_insertion_queue", qos: .default, attributes: .concurrent, autoreleaseFrequency: .never, target: .none)
    }
    
    private var summons: [Summon] {
        get {
            return summon_list_view_controller.get_summons()
        }
        set {
            summon_list_view_controller.set(summons: newValue)
        }
    }
    
    private func sort_summons() {
        summons.sort(by: summon_sorting.get_comparator())
    }
    
    func add_to_back(summon: Summon) {
        summons.append(summon)
        sort_summons()
        DispatchQueue.main.async {
            self.summon_list_view_controller.data_updated()
        }
    }
    
    func add_to_front(summon: Summon) {
        summons.insert(summon, at: 0)
        sort_summons()
        DispatchQueue.main.async {
            self.summon_list_view_controller.data_updated()
        }
    }
    
    private func summon_already_contained(summon: Summon) -> Bool {
        let result = Util.binarySearch(inputArr: summons, searchItem: summon, comparator: {
            lhs, rhs in
            if lhs.get_id() > rhs.get_id() {
                return 1
            } else if lhs.get_id() == rhs.get_id() {
                return 0
            } else {
                return -1
            }
        })
        return result != nil
    }
    
    func add_to_back(data: NSArray) {
        for object in data {
            if let summon_data = object as? NSDictionary {
                let summon = Summon.from(data: summon_data)
                summons.append(summon)
                sort_summons()
                DispatchQueue.main.async {
                    self.summon_list_view_controller.data_updated()
                }
            } else {
                print("ERROR: Invalid friend data")
            }
        }
    }
    
    func add_to_front(data: NSArray) {
        for object in data {
            if let summon_data = object as? NSDictionary {
                let summon = Summon.from(data: summon_data)
                summons.insert(summon, at: 0)
                sort_summons()
                DispatchQueue.main.async {
                    self.summon_list_view_controller.data_updated()
                }
            } else {
                print("ERROR: Invalid friend data")
            }
        }
    }
    
    func delete_summon(id: Int) {
        if summons.count > 0 {
            var summons_copy = summons
            for i in stride(from: summons.count - 1, to: 0, by: -1) {
                let summon = summons[i]
                if summon.get_id() == id {
                    summons_copy.remove(at: i)
                }
            }
            summons = summons_copy
            summon_list_view_controller.data_updated()
        }
    }
    
}
