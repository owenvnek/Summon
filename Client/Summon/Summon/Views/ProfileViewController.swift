//
//  ProfileViewController.swift
//  Summon
//
//  Created by Owen Vnek on 12/26/19.
//  Copyright © 2019 Nio. All rights reserved.
//

import UIKit
import SocketIO
import RSKImageCropper

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var save_button: UIButton!
    @IBOutlet weak var profile_image: UIImageView!
    @IBOutlet weak var name_text_field: UITextField!
    @IBOutlet weak var change_button: UIButton!
    @IBOutlet weak var name_label: UILabel!
    private var image_picker_controller: UIImagePickerController!
    private var image_changed: Bool!
    private var cool_down: Bool!
    
    override func viewDidLoad() {
        let call_back_send_account: NormalCallback = { dataArray, ack in
            //self.send_account(data: dataArray)
        }
        let call_back_profile_save_successful: NormalCallback = { dataArray, ack in
            self.profile_save_successful()
        }
        let call_back_failed_to_save_profile: NormalCallback = {
            dataArray, ack in
            self.failed_to_save_profile(data: dataArray)
        }
        //SocketIOManager.sharedInstance.listen(event_name: "send_account", call_back: call_back_send_account)
        SocketIOManager.sharedInstance.listen(event_name: "profile_save_successful", call_back: call_back_profile_save_successful)
        SocketIOManager.sharedInstance.listen(event_name: "failed_to_save_profile", call_back: call_back_failed_to_save_profile)
        //SocketIOManager.sharedInstance.send(event_name: //"request_account", items: [
            //"username": SummonUserContext.username
        //])
        image_changed = false
        profile_image.layer.cornerRadius = profile_image.frame.height / 2
        profile_image.layer.masksToBounds = true
        name_text_field.delegate = self
        name_text_field.font = UIFont(name: SummonUserContext.font_name, size: name_text_field.font!.pointSize)
        name_label.font = UIFont(name: SummonUserContext.font_name, size: name_label.font!.pointSize)
        change_button.titleLabel!.font = UIFont(name: SummonUserContext.bold_font_name, size: change_button.titleLabel!.font!.pointSize)
        save_button.titleLabel!.font = UIFont(name: SummonUserContext.bold_font_name, size: save_button.titleLabel!.font!.pointSize)
        name_text_field.setBottomBorder()
        cool_down = false
        name_text_field.text = SummonUserContext.me!.get_name()
        name_label.text = SummonUserContext.me!.get_username()
        profile_image.image = SummonUserContext.me!.get_image()
    }
    
    /**
    func send_account(data: [Any]) {
        if let account_data = data[0] as? NSDictionary {
            if !(account_data["name"] is NSNull) {
                let name = account_data["name"] as! String
                name_text_field.text = name
            }
            if !(account_data["image"] is NSNull) {
                let image_data = account_data["image"] as! NSDictionary
                let inner_image_data = image_data["data"] as! [UInt8]
                let data_object = Data(bytes: inner_image_data, count: inner_image_data.count)
                let image = UIImage(data: data_object)
                profile_image.image = image
            }
            name_label.text = SummonUserContext.username
        } else {
            print("ERROR: No Data")
        }
    }
 */
    
    func profile_save_successful() {
        name_text_field.resignFirstResponder()
        let alert = UIAlertController(title: "Saved Profile", message: "Successfully saved your profile", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
            alert in
            self.cool_down = false
        }))
        image_changed = false
        present(alert, animated: true, completion: nil)
    }
    
    func failed_to_save_profile(data: [Any]) {
        if let reason_data = data[0] as? NSDictionary {
            if let reason = reason_data["reason"] as? String {
                let alert = UIAlertController(title: "Failed to Save Profile", message: reason, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
                    alert in
                    self.cool_down = false
                }))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func change_image_button_pressed(_ sender: Any) {
        image_picker_controller = UIImagePickerController()
        image_picker_controller.delegate = self
        image_picker_controller.allowsEditing = false
        image_picker_controller.mediaTypes = ["public.image", "public.movie"]
        image_picker_controller.sourceType = .savedPhotosAlbum
        present(image_picker_controller, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = (info[.originalImage] as! UIImage).resized(toWidth: 200)!
        image_picker_controller.dismiss(animated: true, completion: { () -> Void in
            var imageCropVC : RSKImageCropViewController!
            imageCropVC = RSKImageCropViewController(image: image, cropMode: RSKImageCropMode.circle)
            imageCropVC.delegate = self
            self.image_changed = true
            self.navigationController?.pushViewController(imageCropVC, animated: true)
        })
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        //profile_image.image = croppedImage
        let image_data = croppedImage.jpegData(compressionQuality: 0.000)
        profile_image.image = UIImage(data: image_data!)
        navigationController?.popViewController(animated: true)
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        
    }
    
    @IBAction func save_button_pressed(_ sender: Any) {
        var data: [String: Any] = [:]
        if cool_down {
            return
        }
        data["username"] = SummonUserContext.me!.get_username()
        if image_changed {
            let image_data = profile_image.image!.jpegData(compressionQuality: 0.001)
            data["image"] = image_data
        } else {
            data["image"] = nil
        }
        data["name"] = name_text_field.text!
        SocketIOManager.sharedInstance.send(event_name: "save_profile", items: data)
        cool_down = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
}
