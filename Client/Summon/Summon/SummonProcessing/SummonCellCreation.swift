//
//  SummonProcessing.swift
//  Summon
//
//  Created by Owen Vnek on 2/3/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import UIKit

class SummonCellCreation {
    
    private var summon_list_view_controller: SummonListViewController
    
    init(summon_list_view_controller: SummonListViewController) {
        self.summon_list_view_controller = summon_list_view_controller
    }
    
    private var summons: [Summon] {
        get {
            return summon_list_view_controller.get_summons()
        }
    }
    
    private var summon_list_mode: SummonListMode {
        get {
            return summon_list_view_controller.get_summon_list_mode()
        }
    }
    
    private func in_bounds(index: Int) -> Bool {
        return index < summons.count
    }
    
    private func participants_to_string(participants: [User]) -> String {
        var result = ""
        for i in 0..<participants.count {
            result = "\(result)\(participants[i].get_name())"
            if i != participants.count - 1 {
                result = "\(result), "
            }
        }
        return result
    }
    
    private func remove_self_from(participants: inout [User]) {
        for i in stride(from: participants.count, to: 0, by: -1) {
            let participant = participants[i - 1]
            if participant.get_username() == SummonUserContext.me!.get_username() {
                participants.remove(at: i - 1)
            }
        }
    }
    
    private func configure_incoming(cell: SummonCellView, summon: Summon) {
        var participants = summon.get_participants()
        let owner = summon.get_owner()
        cell.set(owner: "From: \(owner.get_name())")
        remove_self_from(participants: &participants)
        if participants.count > 0 {
            cell.set(participants: "To: You & \(participants_to_string(participants: participants))")
        } else {
            cell.set(participants: "To: You")
        }
    }
    
    private func configure_outgoing(cell: SummonCellView, summon: Summon) {
        let participants = summon.get_participants()
        cell.set(owner: "From: You")
        cell.set(participants: "To: \(participants_to_string(participants: participants))")
    }
    
    private func configure_cell(cell: SummonCellView, index: Int) {
        let summon = summons[index]
        let title = summon.get_title()
        let datetime = summon.get_datetime()
        cell.set(title: title)
        if summon_list_mode == .incoming {
            configure_incoming(cell: cell, summon: summon)
        } else if summon_list_mode == .outgoing {
            configure_outgoing(cell: cell, summon: summon)
        }
        cell.set(datetime: datetime.to_string())
        cell.set(image: summon.get_owner().get_image())
        cell.selectionStyle = .none
    }
    
    func create_cell(indexPath: IndexPath) -> SummonCellView {
        if let cell = summon_list_view_controller.dequeue_cell() {
            let index = indexPath.row
            if in_bounds(index: index) {
                configure_cell(cell: cell, index: index)
            }
            return cell
        }
        fatalError("ERROR: Failed to create cell")
    }
    
    func create_empty_cell(empty_message: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "empty_cell")
        cell.textLabel?.text = empty_message
        cell.textLabel?.font = UIFont(name: SummonUserContext.bold_font_name, size: 30)
        return cell
    }

}
    
public enum SummonListMode {
    
    case incoming
    case outgoing
    
}
