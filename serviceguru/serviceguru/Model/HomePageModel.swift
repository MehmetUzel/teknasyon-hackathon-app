//
//  HomePageModel.swift
//  serviceguru
//
//  Created by Macbook on 8.07.2023.
//

import SwiftUI

/*
 Return : 0 means not exist
 Return : 1 means employee
 Return : 2 means driveremployee
 Return : 3 means admin
 */

func getRole() -> Int {
    let role = UserDefaults.standard.integer(forKey: "userRole")
    return role
}

func updateRole(role: Int) {
    UserDefaults.standard.set(role, forKey: "userRole")
}

func getId() -> String {
    let user_id = UserDefaults.standard.string(forKey: "userID")
    return user_id ?? "none"
}

func setID(user_id: String) {
    UserDefaults.standard.set(user_id, forKey: "userID")
}


class HomePageModel: ObservableObject{
    @Published var send_panel: Bool = false
    @Published var is_home: Bool = true
    @Published var role: Int = getRole()
    @Published var user_id: String = getId()
    @Published var data_ready: Bool = false
}

