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
    
    @Published var isVkConnected = true
    @Published var isOkConnected = true
    
    init() {
        loadUserData()
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
            
        }
        
    }
    
    func didFailGettingGetProfileDataWithError(error: String) {
        print("Error with GetProfileDataManager ")
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
