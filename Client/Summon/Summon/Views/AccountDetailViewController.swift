//
//  AccountDetailViewController.swift
//  Summon
//
//  Created by Owen Vnek on 1/7/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import UIKit
import SocketIO

class AccountDetailViewController: UIViewController {
    
    @IBOutlet weak var name_label: UILabel!
    @IBOutlet weak var username_label: UILabel!
    @IBOutlet weak var profile_image: UIImageView!
    @IBOutlet weak var remove_friend: UIButton!
    @IBOutlet weak var status_message: UILabel!
    @IBOutlet weak var join_date_label: UILabel!
    private var friend_list: UserSelectionViewController?
    private var user: User!
    
    override func viewDidLoad() {
        let call_back_friend_removed: NormalCallback = {
            data, ack in
            self.friend_removed()
        }
        let call_back_friend_added: NormalCallback = {
            data, ack in
            self.friend_added()
        }
        SocketIOManager.sharedInstance.listen(event_name: "friend_removed", call_back: call_back_friend_removed)
        SocketIOManager.sharedInstance.listen(event_name: "friend_added", call_back: call_back_friend_added)
        load_to_display()
        AppearanceConfig.shared.account_detail(account_detail_view_controller: self)
    }
    
    @IBAction func remove_friend_button_pressed(_ sender: Any) {
        displayActionSheet()
    }
    
    private func load_to_display() {
        name_label.text = user.get_name()
        username_label.text = user.get_username()
        profile_image.image = user.get_image()
        name_label.textColor = User.color_for(status_level: user.get_status_level())
        username_label.textColor = User.color_for(status_level: user.get_status_level())
        join_date_label.text = "Joined \(user.get_join_date().to_string_date_only())"
        if user.get_username() == SummonUserContext.me!.get_username() {
            remove_friend.isHidden = true
        }
        if user.get_status_message() != nil {
            status_message.textColor = User.color_for(status_level: user.get_status_level())
            status_message.text = user.get_status_message()!
        } else {
            status_message.isHidden = true
        }
    }
    
    func set(user: User) {
        self.user = user
    }
    
    func set(friend_list: UserSelectionViewController) {
        self.friend_list = friend_list
    }
    
    func friend_removed() {
        let alert = UIAlertController(title: "Friend Removed", message: "Successfully removed that user from your friends list", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
            alert in
            if self.friend_list != nil {
                self.friend_list?.remove_user_with(username: self.user.get_username())
            }
            self.navigationController?.popViewController(animated: true)
        }))
        user.unmark_friend()
        present(alert, animated: true, completion: nil)
    }
    
    func displayActionSheet() {
        let optionMenu = UIAlertController(title: nil, message: "Change User Status", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(cancelAction)
        if user.is_friend() {
            let remove_friend_option = UIAlertAction(title: "Remove Friend", style: .destructive, handler: {
                alert in
                self.confirm_remove_friend()
            })
            optionMenu.addAction(remove_friend_option)
        } else {
            let add_friend_option = UIAlertAction(title: "Add Friend", style: .default, handler: {
                alert in
                self.add_friend()
            })
            optionMenu.addAction(add_friend_option)
        }
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func confirm_remove_friend() {
        let alert = UIAlertController(title: "Remove friend?", message: "Are you sure you would like to remove this user as a friend?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {
            alert in
            self.execute_remove_friend()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func execute_remove_friend() {
        SocketIOManager.sharedInstance.send(event_name: "remove_friend", items: [
            "username": SummonUserContext.me!.get_username(),
            "friend_username": self.user.get_username()
        ])
    }
    
    func add_friend() {
        let data = [
            "username": SummonUserContext.me!.get_username(),
            "friend_username": self.user.get_username()
        ] as [String : Any]
        SocketIOManager.sharedInstance.send(event_name: "add_friend", items: data)
    }
    
    func friend_added() {
        let alert = UIAlertController(title: "Friend Added", message: "Successfully added that user to your friends list", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { alert in
            //Probably should add a way to tell the friends list to update
            /**
            let request_id = SummonUserContext.get_request_id()
            let data = [
                "username": SummonUserContext.username,
                "request_id": request_id,
                "source": "queue"
                ] as [String : Any]
            self.friends_view_controller.set(request_id: request_id)
            SocketIOManager.sharedInstance.send(event_name: "request_friends", items: data)
            self.navigationController?.popViewController(animated: true)
 */
        }))
        user.mark_friend()
        present(alert, animated: true, completion: nil)
    }
    
}
