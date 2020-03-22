//
//  SummonDetailInteraction.swift
//  Summon
//
//  Created by Owen Vnek on 2/5/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import UIKit
import MapKit
import SocketIO

class SummonDetailInteraction {
    
    private var summon_detail_view_controller: SummonDetailViewController
    
    init(summon_detail_view_controller: SummonDetailViewController) {
        self.summon_detail_view_controller = summon_detail_view_controller
    }
    
    func get_location() -> Location? {
        return summon_detail_view_controller.get_location()
    }
    
    func get_location_label_text() -> String {
        return summon_detail_view_controller.get_location_label_text()
    }
    
    func get_owner() -> User {
        return get_summon().get_owner()
    }
    
    func get_summon() -> Summon {
        return summon_detail_view_controller.get_summon()
    }
    
    func get_participants() -> [User] {
        return get_summon().get_participants()
    }
    
    func get_user_selection_view_controller() -> UserSelectionViewController {
        return summon_detail_view_controller.get_user_selection_view_controller()
    }
    
    func get_summon_list_view_controller() -> SummonListViewController {
        return summon_detail_view_controller.get_summon_list_view_controller()
    }
    
    func set(location_label_text: String) {
        summon_detail_view_controller.set(location_label_text: location_label_text)
    }
    
    func set(user_selection_view_controller: UserSelectionViewController) {
        summon_detail_view_controller.set(user_selection_view_controller: user_selection_view_controller)
    }
    
    func hide_location_label() {
        summon_detail_view_controller.hide_location_label()
    }
    
    func process_location() {
        if get_location() != nil {
            let placemark = get_location()!.get_placemark()
            if get_location()!.get_name() != nil {
                let name = get_location()!.get_name()!
                set(location_label_text: "\(name) \(placemark.locality!) \(placemark.administrativeArea!)")
            } else {
                set(location_label_text: "\(placemark.locality!) \(placemark.administrativeArea!)")
            }
        } else {
            hide_location_label()
        }
    }
    
    func add_gesture_recognizers() {
        let tapped1 = UITapGestureRecognizer(target: self, action: #selector(show_owner_detail))
        let tapped2 = UITapGestureRecognizer(target: self, action: #selector(show_owner_detail))
        let tapped3 = UITapGestureRecognizer(target: self, action: #selector(show_maps))
        summon_detail_view_controller.owner_label.isUserInteractionEnabled = true
        summon_detail_view_controller.owner_label.addGestureRecognizer(tapped1)
        summon_detail_view_controller.profile_image.isUserInteractionEnabled = true
        summon_detail_view_controller.profile_image.addGestureRecognizer(tapped2)
        summon_detail_view_controller.location_label.isUserInteractionEnabled = true
        summon_detail_view_controller.location_label.addGestureRecognizer(tapped3)
    }
    
    @objc func show_owner_detail() {
        summon_detail_view_controller.performSegue(withIdentifier: "owner_detail", sender: self)
    }
    
    func check_ownership() {
        if get_owner().get_username() == SummonUserContext.me!.get_username() {
            summon_detail_view_controller.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(delete_summon))
            summon_detail_view_controller.navigationItem.rightBarButtonItem!.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: SummonUserContext.bold_font_name, size: 15)!], for: UIControl.State.normal)
        }
    }
    
    func create_listeners() {
        let call_back_summon_deleted: NormalCallback = { dataArray, ack in
            self.summon_deleted()
        }
        SocketIOManager.sharedInstance.listen(event_name: "summon_deleted", call_back: call_back_summon_deleted)
    }
    
    @objc func delete_summon() {
        let alert = UIAlertController(title: "Delete Summon?", message: "Are you sure that you would like to delete this summon?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {
            action in
            SocketIOManager.sharedInstance.send(event_name: "delete_summon", items: [
                "summon_id": self.get_summon().get_id()
            ])
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        summon_detail_view_controller.present(alert, animated: true, completion: nil)
    }
    
    @objc func show_maps() {
        let regionDistance:CLLocationDistance = 10000
        let placemark = get_location()!.get_placemark()
        let coordinates = placemark.coordinate
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = get_location()!.get_name()
        mapItem.openInMaps(launchOptions: options)
    }
    
    func summon_deleted() {
        let alert = UIAlertController(title: "Summon Deleted", message: "Successfully deleted your summon", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
            action in
            self.get_summon_list_view_controller().delete_summon(id: self.get_summon().get_id())
            self.summon_detail_view_controller.navigationController?.popViewController(animated: true)
        }))
        summon_detail_view_controller.present(alert, animated: true, completion: nil)
    }
    
}
