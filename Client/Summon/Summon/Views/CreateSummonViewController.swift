//
//  CreateSummonViewController.swift
//  Summon
//
//  Created by Owen Vnek on 12/22/19.
//  Copyright © 2019 Nio. All rights reserved.
//

import UIKit
import SocketIO
import MapKit

class CreateSummonViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var date_picker: UIDatePicker!
    @IBOutlet weak var title_field: UITextField!
    @IBOutlet weak var participants_label: UILabel!
    @IBOutlet weak var edit_button: UIButton!
    @IBOutlet weak var add_button: UIButton!
    private var user_selection_view_controller: UserSelectionViewController!
    private var sent_view_controller: SentViewController!
    @IBOutlet weak var location_text_field: UITextField!
    @IBOutlet weak var navigation_item: UINavigationItem!
    private var location: Location?
    @IBOutlet weak var done_button: UIButton!
    
    override func viewDidLoad() {
        let call_back_summon_created: NormalCallback = { dataArray, ack in
            self.summon_created()
        }
        let call_back_summon_creation_failed: NormalCallback = { dataArray, ack in
            self.summon_creation_failed(data: dataArray)
        }
        SocketIOManager.sharedInstance.listen(event_name: "summon_created", call_back: call_back_summon_created)
        SocketIOManager.sharedInstance.listen(event_name: "summon_creation_failed", call_back: call_back_summon_creation_failed)
        title_field.delegate = self
        location_text_field.isUserInteractionEnabled = false
        participants_label.font = UIFont(name: SummonUserContext.font_name, size: participants_label.font!.pointSize)
        title_field.font = UIFont(name: SummonUserContext.font_name, size: title_field.font!.pointSize)
        location_text_field.font = UIFont(name: SummonUserContext.font_name, size: location_text_field.font!.pointSize)
        edit_button.titleLabel!.font = UIFont(name: SummonUserContext.font_name, size: edit_button.titleLabel!.font!.pointSize)
        add_button.titleLabel!.font = UIFont(name: SummonUserContext.font_name, size: add_button.titleLabel!.font!.pointSize)
        done_button.titleLabel!.font = UIFont(name: SummonUserContext.bold_font_name, size: done_button.titleLabel!.font!.pointSize)
        date_picker.date = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        title_field.setBottomBorder()
        location_text_field.setBottomBorder()
    }
    
    func set(location: Location) {
        self.location = location
        let placemark = location.get_placemark()
        if location.get_name() != nil {
            location_text_field.text = "\(location.get_name()!) \(placemark.locality!) \(placemark.administrativeArea!)"
        } else {
            location_text_field.text = "\(placemark.locality!) \(placemark.administrativeArea!)"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if destination is UserSelectionViewController {
            let user_selection_view: UIView
            user_selection_view_controller = destination as? UserSelectionViewController
            user_selection_view = user_selection_view_controller.view
            user_selection_view.layer.borderColor = UIColor.lightGray.cgColor
            user_selection_view.layer.borderWidth = 1
            user_selection_view_controller.mark_data_received()
        } else if destination is AddParticipantsViewController {
            let add_participant_view_controller = destination as? AddParticipantsViewController
            add_participant_view_controller?.set(create_summon_view_controller: self)
        } else if destination is LocationSelectionViewController {
            let location_selection_view_controller = destination as? LocationSelectionViewController
            location_selection_view_controller?.set(create_summon_view_controller: self)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    private func save_location() -> [String: Any] {
        let name = location?.get_name() ?? nil
        let placemark = location?.get_placemark()
        let postal_address = placemark?.postalAddress
        let longitude: Any = placemark?.coordinate.longitude ?? nil
        let latitude: Any = placemark?.coordinate.latitude ?? nil
        let street: Any = postal_address?.street ?? nil
        let city: Any = postal_address?.city ?? nil
        let state: Any = postal_address?.state ?? nil
        let postalCode: Any = postal_address?.postalCode ?? nil
        let country: Any = postal_address?.country ?? nil
        let isoCountryCode: Any = postal_address?.isoCountryCode ?? nil
        let subAdministrativeArea: Any = postal_address?.subAdministrativeArea ?? nil
        let subLocality: Any = postal_address?.subLocality ?? nil
        return [
            "name": name,
            "longitude": longitude,
            "latitude": latitude,
            "street": street,
            "city": city,
            "state": state,
            "postalCode": postalCode,
            "country": country,
            "isoCountryCode": isoCountryCode,
            "subAdministrativeArea": subAdministrativeArea,
            "subLocality": subLocality
        ]
    }
    
    @IBAction func done_button_pressed(_ sender: Any) {
        let title_field_value = title_field.text!
        var data = [
            "title": title_field_value,
            "owner": SummonUserContext.me!.get_username(),
            "participants": get_participants_object(),
            "datetime": get_datetime_object(),
            ] as [String : Any]
        if location != nil {
            data["location"] = save_location()
        }
        SocketIOManager.sharedInstance.send(event_name: "create_summon", items: data)
    }
    
    func get_participants_object() -> [Any] {
        var result: [String] = []
        let users = user_selection_view_controller.get_users()
        for user in users {
            result.append(user.get_username())
        }
        return result
    }
    
    func get_datetime_object() -> [String: Any] {
        let calendar = Calendar.current
        let date = date_picker.date
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        return [
            "year": year,
            "month": month,
            "day": day,
            "hour": hour,
            "minute": minute
        ]
    }
    
    func is_friend_already_selected(test_user: User) -> Bool {
        let users = user_selection_view_controller.get_users()
        for user in users {
            if user.get_username() == test_user.get_username() {
                return true
            }
        }
        return false
    }
    
    func add(user: User) {
        user_selection_view_controller.add(user: user)
    }
    
    func set(sent_view_controller: SentViewController) {
        self.sent_view_controller = sent_view_controller
    }
    
    func summon_created() {
        let alert = UIAlertController(title: "Summon Created", message: "Successfully created a new summon", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { alert in
            self.navigationController?.popViewController(animated: true)
            //self.sent_view_controller.reset()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func summon_creation_failed(data: [Any]) {
        if let data_dict = data[0] as? NSDictionary {
            if let reason = data_dict["reason"] as? String {
                let alert = UIAlertController(title: "Failed to Create Summon", message: reason, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func reset_participants() {
        user_selection_view_controller.reset()
    }
    
}
