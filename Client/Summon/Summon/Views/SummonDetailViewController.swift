//
//  SummonDetailViewController.swift
//  Summon
//
//  Created by Owen Vnek on 1/7/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import UIKit
import MapKit
import SocketIO

class SummonDetailViewController: UIViewController {
    
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var location_label: UILabel!
    @IBOutlet weak var owner_label: UILabel!
    @IBOutlet weak var datetime_label: UILabel!
    @IBOutlet weak var profile_image: UIImageView!
    private var summon: Summon!
    private var title_str: String!
    private var location: Location!
    private var owner: User!
    private var participants: [User] = []
    private var datetime: String!
    private var user_selection_view_controller: UserSelectionViewController!
    private var summon_list_view_controller: SummonListViewController!
    private var summon_detail_interaction: SummonDetailInteraction!
    
    override func viewWillLayoutSubviews() {
        summon_detail_interaction = SummonDetailInteraction(summon_detail_view_controller: self)
        summon_detail_interaction.process_location()
        summon_detail_interaction.check_ownership()
        summon_detail_interaction.create_listeners()
        summon_detail_interaction.add_gesture_recognizers()
    }
    
    override func viewDidLoad() {
        load_to_display()
        AppearanceConfig.shared.summon_detail(summon_detail_view_controller: self)
    }

    private func load_to_display() {
        title_label.text = title_str
        owner_label.text = owner.get_name()
        profile_image.image = owner.get_image()
        datetime_label.text = datetime
        owner_label.textColor = User.color_for(status_level: owner.get_status_level())
    }
    
    func get_location() -> Location? {
        return location
    }
    
    func get_location_label_text() -> String {
        return location_label.text!
    }
    
    func get_summon() -> Summon {
        return summon
    }
    
    func get_user_selection_view_controller() -> UserSelectionViewController {
        return user_selection_view_controller
    }
    
    func get_summon_list_view_controller() -> SummonListViewController {
        return summon_list_view_controller
    }
    
    func set(location_label_text: String) {
        location_label.text = location_label_text
    }
    
    func set(user_selection_view_controller: UserSelectionViewController) {
        self.user_selection_view_controller = user_selection_view_controller
    }
    
    func set(summon: Summon) {
        self.summon = summon
    }
    
    func set(title: String) {
        title_str = title
    }
    
    func set(location: Location?) {
        self.location = location
    }
    
    func set(owner: User) {
        self.owner = owner
    }
    
    func set(datetime: String) {
        self.datetime = datetime
    }
    
    func set(summon_list_view_controller: SummonListViewController) {
        self.summon_list_view_controller = summon_list_view_controller
    }
    
    func add(participant: User) {
        self.participants.append(participant)
    }
    
    func hide_location_label() {
         location_label.isHidden = true
     }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UserSelectionViewController {
            set(user_selection_view_controller: destination)
            for participant in summon.get_participants() {
                destination.add(user: participant)
            }
            destination.mark_data_received()
            destination.data_updated_direct()
            destination.set(call_back: { username in
                destination.show_detail()
            })
        } else if let destination = segue.destination as? AccountDetailViewController {
            destination.set(user: summon.get_owner())
        }
    }
    
    @objc func show_owner_detail() {
        performSegue(withIdentifier: "owner_detail", sender: self)
    }
    
}
