//
//  AppearanceConfig.swift
//  Summon
//
//  Created by Owen Vnek on 2/4/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import UIKit

class AppearanceConfig {
    
    static let shared: AppearanceConfig = AppearanceConfig()
    
    func login(login_view_controller: LoginViewController) {
        login_view_controller.username_field.font = UIFont(name: SummonUserContext.font_name, size: login_view_controller.username_field.font!.pointSize)
        login_view_controller.password_field.font = UIFont(name: SummonUserContext.font_name, size: login_view_controller.username_field.font!.pointSize)
        login_view_controller.login_label.font = UIFont(name: SummonUserContext.bold_font_name, size: login_view_controller.username_field.font!.pointSize)
        login_view_controller.login_button.titleLabel?.font = UIFont(name: SummonUserContext.bold_font_name, size: login_view_controller.login_button.titleLabel!.font!.pointSize)
        login_view_controller.create_account_button.titleLabel?.font = UIFont(name: SummonUserContext.bold_font_name, size: login_view_controller.create_account_button.titleLabel!.font!.pointSize)
        login_view_controller.username_field.borderStyle = UITextField.BorderStyle.none
        login_view_controller.username_field.setBottomBorder()
        login_view_controller.password_field.borderStyle = UITextField.BorderStyle.none
        login_view_controller.password_field.setBottomBorder()
    }
    
    func create_account(create_account_view_controller: CreateAccountViewController) {
        create_account_view_controller.create_account_label.font = UIFont(name: SummonUserContext.bold_font_name, size: create_account_view_controller.create_account_label.font!.pointSize)
        create_account_view_controller.username.font = UIFont(name: SummonUserContext.font_name, size: create_account_view_controller.username.font!.pointSize)
        create_account_view_controller.name.font = UIFont(name: SummonUserContext.font_name, size: create_account_view_controller.name.font!.pointSize)
        create_account_view_controller.password.font = UIFont(name: SummonUserContext.font_name, size: create_account_view_controller.password.font!.pointSize)
        create_account_view_controller.repeat_password.font = UIFont(name: SummonUserContext.font_name, size: create_account_view_controller.repeat_password.font!.pointSize)
        create_account_view_controller.submit_button.titleLabel?.font = UIFont(name: SummonUserContext.bold_font_name, size: create_account_view_controller.submit_button.titleLabel!.font!.pointSize)
        create_account_view_controller.username.setBottomBorder()
        create_account_view_controller.name.setBottomBorder()
        create_account_view_controller.password.setBottomBorder()
        create_account_view_controller.repeat_password.setBottomBorder()
    }
    
    func summon_list(table_view: UITableView) {
        table_view.separatorStyle = .none
        table_view.tableFooterView = UIView(frame: .zero)
        table_view.tableFooterView?.backgroundColor = .lightGray
        table_view.tableFooterView?.tintColor = .lightGray
    }
    
    func loading(loading_view_controller: LoadingViewController) {
        loading_view_controller.status_label.text = "Trying to connect to Summon servers"
        loading_view_controller.activity_indicator.startAnimating()
        loading_view_controller.activity_indicator.contentScaleFactor = 3
        loading_view_controller.summon_label.font = UIFont(name: SummonUserContext.bold_font_name, size: loading_view_controller.summon_label.font!.pointSize)
        loading_view_controller.status_label.font = UIFont(name: SummonUserContext.font_name, size: loading_view_controller.status_label.font!.pointSize)
    }
    
    func account_detail(account_detail_view_controller: AccountDetailViewController) {
        account_detail_view_controller.profile_image.layer.cornerRadius = account_detail_view_controller.profile_image.frame.height / 2
        account_detail_view_controller.profile_image.layer.masksToBounds = true
        account_detail_view_controller.name_label.font = UIFont(name: SummonUserContext.bold_font_name, size: account_detail_view_controller.name_label.font!.pointSize)
        account_detail_view_controller.username_label.font = UIFont(name: SummonUserContext.font_name, size: account_detail_view_controller.username_label.font!.pointSize)
        account_detail_view_controller.remove_friend.titleLabel!.font = UIFont(name: SummonUserContext.font_name, size: account_detail_view_controller.remove_friend.titleLabel!.font!.pointSize)
        account_detail_view_controller.status_message.font = UIFont(name: SummonUserContext.bold_font_name, size: account_detail_view_controller.status_message.font!.pointSize)
        account_detail_view_controller.join_date_label.font = UIFont(name: SummonUserContext.bold_font_name, size: account_detail_view_controller.join_date_label.font!.pointSize)
        account_detail_view_controller.username_label.font = UIFont(name: SummonUserContext.bold_font_name, size: account_detail_view_controller.username_label.font!.pointSize)
    }
    
    func summon_detail(summon_detail_view_controller: SummonDetailViewController) {
        summon_detail_view_controller.title_label.font = UIFont(name: SummonUserContext.font_name, size: summon_detail_view_controller.title_label.font!.pointSize)
        summon_detail_view_controller.owner_label.font = UIFont(name: SummonUserContext.font_name, size: summon_detail_view_controller.owner_label.font!.pointSize)
        summon_detail_view_controller.datetime_label.font = UIFont(name: SummonUserContext.font_name, size: summon_detail_view_controller.datetime_label.font!.pointSize)
        summon_detail_view_controller.location_label.font = UIFont(name: SummonUserContext.font_name, size: summon_detail_view_controller.location_label.font!.pointSize)
        summon_detail_view_controller.profile_image.layer.cornerRadius = summon_detail_view_controller.profile_image.frame.height / 2
        summon_detail_view_controller.profile_image.layer.masksToBounds = true
    }
    
}
