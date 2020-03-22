//
//  InboxViewController.swift
//  Summon
//
//  Created by Owen Vnek on 1/3/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import UIKit
import SocketIO

class InboxViewController: UIViewController {
    
    private var summon_list_view_controller: SummonListViewController!
    @IBOutlet weak var profile_image: UIImageView!
    @IBOutlet weak var name_label: UILabel!
    
    override func viewDidLoad() {
        let call_back_send_incoming_summon: NormalCallback = { dataArray, ack in
            self.send_incoming_summon(dataArray: dataArray)
        }
        let call_back_summon_enqueued: NormalCallback = {
            dataArray, ack in
            self.summon_enqueued()
        }
        let call_back_reconnect: NormalCallback = {
            dataArray, ack in
            self.reconnect()
        }
        if SummonUserContext.me != nil {
            let data = [
                "username": SummonUserContext.me!.get_username(),
                "source": "all"
            ]
            SocketIOManager.sharedInstance.send(event_name: "request_incoming_summons", items: data)
        }
        SocketIOManager.sharedInstance.listen(event_name: "send_incoming_summon", call_back: call_back_send_incoming_summon)
        SocketIOManager.sharedInstance.listen(event_name: "summon_enqueued", call_back: call_back_summon_enqueued)
        SocketIOManager.sharedInstance.listen(event_name: "reconnect", call_back: call_back_reconnect)
        summon_list_view_controller.set(empty_message: "Your inbox is empty")
        if SummonUserContext.me != nil {
            name_label.text = SummonUserContext.me!.get_name()
            profile_image.image = SummonUserContext.me!.get_image()
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
        name_label.font = UIFont(name: SummonUserContext.bold_font_name, size: name_label.font!.pointSize)
        profile_image.layer.cornerRadius = profile_image.frame.height / 2
        profile_image.layer.masksToBounds = true
        name_label.isUserInteractionEnabled = true
        profile_image.isUserInteractionEnabled = true
        name_label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(show_profile)))
        profile_image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(show_profile)))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "summon_list" {
            summon_list_view_controller = segue.destination as? SummonListViewController
            summon_list_view_controller.set(summon_list_mode: .incoming)
        }
    }
    
    func send_incoming_summon(dataArray: [Any]) {
        if let dict = dataArray[0] as? NSDictionary {
            let array = dict["summons"] as! NSArray
            let source = dict["source"] as! String
            if let vc = summon_list_view_controller {
                if source == "queue" {
                    vc.add_to_front(data: array)
                } else if source == "all" {
                    vc.add_to_back(data: array)
                }
            }
        } else {
            print("ERROR: No Data")
        }
    }
    
    func summon_enqueued() {
        let data = [
            "username": SummonUserContext.me!.get_username(),
            "source": "queue"
        ]
        SocketIOManager.sharedInstance.send(event_name: "request_incoming_summons", items: data)
    }
    
    func reconnect() {
        let data = [
            "username": SummonUserContext.me!.get_username(),
            "source": "queue"
        ]
        SocketIOManager.sharedInstance.send(event_name: "request_incoming_summons", items: data)
    }
    
    @objc func show_profile() {
        SummonUserContext.tabbar_controller?.selectedIndex = 3
    }
    
}

