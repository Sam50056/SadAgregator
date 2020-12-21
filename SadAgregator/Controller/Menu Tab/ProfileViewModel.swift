//
//  ProfileViewModel.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 21.12.2020.
//

import Foundation

class ProfileViewModel : ObservableObject{
    
    @Published var alertTitle = ""
    @Published var isAlertShown = false
    @Published var alertTextFieldText = ""
    
    @Published var isPassAlertShown = false
    
    @Published var isVkConnected = true
    @Published var isOkConnected = true
    
}
