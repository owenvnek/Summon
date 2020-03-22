//
//  FriendsViewController.swift
//  Summon
//
//  Created by Owen Vnek on 12/23/19.
//  Copyright © 2019 Nio. All rights reserved.
//

import UIKit
import SocketIO

class FriendsViewController: UIViewController {
    
    @IBOutlet weak var search_bar: UISearchBar!
    @IBOutlet weak var user_list_view: UIView!
    private var user_selection_view_controller: UserSelectionViewController?
    private var request_id: Int!
    private var insertion_queue: DispatchQueue!
    
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
        insertion_queue = DispatchQueue(label: "insertion_queue", qos: .default, attributes: .concurrent, autoreleaseFrequency: .never, target: .none)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "user_selection" {
            user_selection_view_controller = segue.destination as? UserSelectionViewController
            user_selection_view_controller?.set(call_back: { username in
                self.user_selection_view_controller?.show_detail()
            })
        } else if let destination = segue.destination as? AddFriendViewController {
            destination.set(friends_view_controller: self)
        }
    }
    
    func send_friends(dataArray: [Any]) {
        insertion_queue.async {
            let data = dataArray[0] as! NSDictionary
            let request_id = data["request_id"] as! Int
            if self.request_id == request_id {
                if let array = data["friends"] as? NSArray {
                    if let vc = self.user_selection_view_controller {
                        for object in array {
                            if let friend = object as? NSDictionary {
                                let user = User.from(data: friend)
                                user.mark_friend()
                                vc.add(user: user)
                            }
                        }
                        vc.mark_data_received()
                        vc.data_updated()
                    } else {
                        print("ERROR: No User Selection View Controller")
                    }
                } else {
                    print("ERROR: No Data")
                }
            }

        }
    }
    
    func set(request_id: Int) {
        self.request_id = request_id
    }
    
}
