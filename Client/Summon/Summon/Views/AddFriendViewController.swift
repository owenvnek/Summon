//
//  AddFriendViewController.swift
//  Summon
//
//  Created by Owen Vnek on 12/23/19.
//  Copyright © 2019 Nio. All rights reserved.
//

import UIKit
import SocketIO

class AddFriendViewController: UIViewController {
    
    @IBOutlet weak var text_field: UITextField!
    private var friends_view_controller: FriendsViewController!
    @IBOutlet weak var add_button: UIButton!
    
    override func viewDidLoad() {
        let call_back_friend_added: NormalCallback = { dataArray, ack in
            self.friend_added()
        }
        let call_back_friendship_failed: NormalCallback = { dataArray, ack in
            self.friendship_failed(dataArray: dataArray)
        }
        SocketIOManager.sharedInstance.listen(event_name: "friend_added", call_back: call_back_friend_added)
        SocketIOManager.sharedInstance.listen(event_name: "friendship_failed", call_back: call_back_friendship_failed)
        text_field.font = UIFont(name: SummonUserContext.font_name, size: text_field.font!.pointSize)
        add_button.titleLabel!.font = UIFont(name: SummonUserContext.bold_font_name, size: add_button.titleLabel!.font!.pointSize)
        text_field.setBottomBorder()
    }
    
    @IBAction func add_button_pressed(_ sender: Any) {
        let data = [
            "username": SummonUserContext.me!.get_username(),
            "friend_username": text_field.text!
        ] as [String : Any]
        SocketIOManager.sharedInstance.send(event_name: "add_friend", items: data)
    }
    
    func friendship_failed(dataArray: [Any]) {
        if let typeDict = dataArray[0] as? NSDictionary {
            let reason = typeDict["reason"] as! String
            let alert = UIAlertController(title: "Failed to Add Friend", message: reason, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func friend_added() {
        let alert = UIAlertController(title: "Friend Added", message: "Successfully added that user to your friends list", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { alert in
            let request_id = SummonUserContext.get_request_id()
            let data = [
                "username": SummonUserContext.me!.get_username(),
                "request_id": request_id,
                "source": "queue"
                ] as [String : Any]
            self.friends_view_controller.set(request_id: request_id)
            SocketIOManager.sharedInstance.send(event_name: "request_friends", items: data)
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func set(friends_view_controller: FriendsViewController) {
        self.friends_view_controller = friends_view_controller
    }
    
}
