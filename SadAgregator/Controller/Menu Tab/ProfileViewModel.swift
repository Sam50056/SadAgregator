//
//  ProfileViewModel.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 21.12.2020.
//

import Foundation
import SwiftyJSON
import RealmSwift

class ProfileViewModel : ObservableObject{
    
    let realm = try! Realm()
    
    @Published var key = ""
    
    @Published var name = ""
    @Published var phone = ""
    @Published var email  = ""
    @Published var partnerCode = ""
    @Published var password = ""
    
    @Published var alertTitle = ""
    @Published var isAlertShown = false
    @Published var alertTextFieldText = ""
    
    @Published var isPassAlertShown = false
    @Published var oldPassText = ""
    @Published var newPassText = ""
    @Published var confirmPassText = ""
    
    @Published var isVkConnected : Bool?
    @Published var isOkConnected : Bool?
    
    lazy var userChangeOptionDataManager = UserChangeOptionDataManager()
    
    init() {
        
        loadUserData()
        
        userChangeOptionDataManager.delegate = self
        
    }
    
}

//MARK: - GetProfileDataManagerDelegate

extension ProfileViewModel : GetProfileDataManagerDelegate {
    
    func getProfileData(){
        
        GetProfileDataManager(delegate: self).getGetProfileData(key: key)
        
    }
    
    func didGetGetProfileData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            name = data["user"]["name"].stringValue
            
            phone = data["user"]["phone"].stringValue
            
            email = data["user"]["email"].stringValue
            
            partnerCode = data["user"]["partner_code"].stringValue
            
            password = "*********"
            
            isOkConnected = data["user"]["ok_token"].stringValue != ""
            isVkConnected = data["user"]["vk_token"].stringValue != ""
            
        }
        
    }
    
    func didFailGettingGetProfileDataWithError(error: String) {
        print("Error with GetProfileDataManager ")
    }
    
}

//MARK: - UserChangeOptionDataManagerDelegate

extension ProfileViewModel : UserChangeOptionDataManagerDelegate{
    
    func changeUserOption(){
        
        userChangeOptionDataManager.getUserChangeOptionData(key: key, infoType: (alertTitle == "Имя" ? 1 : 2), newValue: alertTextFieldText)
        
    }
    
    func didGetUserChangeOptionData(data: JSON) {
        
        DispatchQueue.main.async {
            
            if data["result"].intValue == 1 {
                
                self.getProfileData()
                
                self.isAlertShown = false
                
                self.alertTextFieldText = ""
                
            }
            
        }
        
    }
    
    func didFailGettingUserChangeOptionDataWithError(error: String) {
        print("Error with UserChangeOptionDataManager: \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension ProfileViewModel {
    
    func loadUserData (){
        
        let userData = realm.objects(UserData.self)
        
        if let userDataObject = userData.first{
            
            key = userDataObject.key
            
            
        }
        
    }
    
}
