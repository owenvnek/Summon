//
//  AddParticipantsViewController.swift
//  Summon
//
//  Created by Owen Vnek on 1/3/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import UIKit
import SocketIO

class AddParticipantsViewController: UIViewController {
    
    private var create_summon_view_controller: CreateSummonViewController!
    private var user_selection_view_controller: UserSelectionViewController!
    private var request_id: Int!
    @IBOutlet weak var done_button: UIButton!
    
    override func viewDidLoad() {
        let call_back_request_friends: NormalCallback = { dataArray, ack in
            self.send_friends(dataArray: dataArray)
        }
        request_id = SummonUserContext.get_request_id()
        let data = [
            "username": SummonUserContext.me!.get_username(),
            "request_id": request_id!,
            "source": "all"
        ] as [String : Any]
        SocketIOManager.sharedInstance.send(event_name: "request_friends", items: data)
        SocketIOManager.sharedInstance.listen(event_name: "send_friend", call_back: call_back_request_friends)
        done_button.titleLabel!.font = UIFont(name: SummonUserContext.bold_font_name, size: done_button.titleLabel!.font!.pointSize)
    }
    
    @IBAction func done_button_pressed(_ sender: Any) {
        let selected_users = user_selection_view_controller.get_selected_users()
        create_summon_view_controller.reset_participants()
        for selected_user in selected_users {
            create_summon_view_controller.add(user: selected_user)
        }
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if destination is UserSelectionViewController {
            user_selection_view_controller = destination as? UserSelectionViewController
            user_selection_view_controller.enable_multi_selection()
            user_selection_view_controller.mark_data_received()
        }
    }
    
    func set(create_summon_view_controller: CreateSummonViewController) {
        self.create_summon_view_controller = create_summon_view_controller
    }
    
    func send_friends(dataArray: [Any]) {
        let data = dataArray[0] as! NSDictionary
        let request_id = data["request_id"] as! Int
        if self.request_id == request_id {
            if let array = data["friends"] as? NSArray {
                if let vc = user_selection_view_controller {
                    for object in array {
                        if let friend = object as? NSDictionary {
                            let user = User.from(data: friend)
                            if !create_summon_view_controller.is_friend_already_selected(test_user: user) {
                                vc.add(user: user)
                            } else {
                                vc.add_selected(user: user)
                            }
                        } else {
                            print("ERROR: Invalid friend data")
                        }
                    }
                } else {
                    print("ERROR: No User Selection View Controller")
                }
            } else {
                print("ERROR: No Data")
            }
        }
    }
    
}
