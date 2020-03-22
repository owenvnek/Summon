//
//  SentViewController.swift
//  Summon
//
//  Created by Owen Vnek on 1/3/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import UIKit
import SocketIO

class SentViewController: UIViewController {
    
    private var summon_list_view_controller: SummonListViewController!
    @IBOutlet weak var profile_image: UIImageView!
    @IBOutlet weak var name_label: UILabel!
    
    override func viewDidLoad() {
        let call_back_send_outgoing_summon: NormalCallback = { dataArray, ack in
            self.send_outgoing_summon(dataArray: dataArray)
        }
        let data = [
            "username": SummonUserContext.me!.get_username(),
            "source": "all"
        ]
        let call_back_summon_created: NormalCallback = { dataArray, ack in
            self.summon_created()
        }
        let call_back_reconnect: NormalCallback = {
            dataArray, ack in
            self.reconnect()
        }
        SocketIOManager.sharedInstance.send(event_name: "request_outgoing_summons", items: data)
        SocketIOManager.sharedInstance.listen(event_name: "send_outgoing_summon", call_back: call_back_send_outgoing_summon)
        SocketIOManager.sharedInstance.listen(event_name: "summon_created", call_back: call_back_summon_created)
        SocketIOManager.sharedInstance.listen(event_name: "reconnect", call_back: call_back_reconnect)
        summon_list_view_controller.set(empty_message: "You haven't sent anything")
        if SummonUserContext.me != nil {
            name_label.text = SummonUserContext.me!.get_name()
            profile_image.image = SummonUserContext.me!.get_image()
        }
        name_label.font = UIFont(name: SummonUserContext.bold_font_name, size: name_label.font!.pointSize)
        profile_image.layer.cornerRadius = profile_image.frame.height / 2
        profile_image.layer.masksToBounds = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "summon_list" {
            summon_list_view_controller = segue.destination as? SummonListViewController
            summon_list_view_controller.set(summon_list_mode: .outgoing)
        } else if segue.identifier == "create_summon" {
            let create_summon_view_controller = segue.destination as? CreateSummonViewController
            create_summon_view_controller?.set(sent_view_controller: self)
        }
    }
    
    func send_outgoing_summon(dataArray: [Any]) {
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
    
    func reset() {
        let data = [
            "username": SummonUserContext.me!.get_username()
        ]
        summon_list_view_controller.reset()
        SocketIOManager.sharedInstance.send(event_name: "request_outgoing_summons", items: data)
    }
    
    func summon_created() {
        let data = [
            "username": SummonUserContext.me!.get_username(),
            "source": "queue"
        ]
        SocketIOManager.sharedInstance.send(event_name: "request_outgoing_summons", items: data)
    }
    
    func reconnect() {
        let data = [
            "username": SummonUserContext.me!.get_username(),
            "source": "queue"
        ]
        SocketIOManager.sharedInstance.send(event_name: "request_outgoing_summons", items: data)
    }
    
}
