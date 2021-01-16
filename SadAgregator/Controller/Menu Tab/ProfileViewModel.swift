//
//  ProfileViewModel.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 21.12.2020.
//

import Foundation
import SwiftyJSON
import RealmSwift
import VK_ios_sdk

class ProfileViewModel : ObservableObject{
    
    let realm = try! Realm()
    
    let vkAuthService = VKAuthService()
    
    @Published var showProfile = false
    
    @Published var key = ""
    @Published var settings = ""
    
    @Published var name = ""
    @Published var phone = ""
    @Published var email  = ""
    @Published var partnerCode = ""
    @Published var password = ""
    @Published var vkExp = ""
    @Published var autoVK = ""
    @Published var okExp = ""
    @Published var autoOK = ""
    
    @Published var alertTitle = "Мы рекомендуем настраивать выгрузку через функцию БЫСТРОЙ НАСТРОЙКИ, это легко для новичков и не требует специальных знаний!"
    @Published var isAlertShown = false
    @Published var customAlertTitle = ""
    @Published var isCustomAlertShown = false
    @Published var customAlertTextFieldText = ""
    
    @Published var isPassAlertShown = false
    @Published var oldPassText = ""
    @Published var newPassText = ""
    @Published var confirmPassText = ""
    
    @Published var isVkConnected : Bool?
    @Published var isOkConnected : Bool?
    
    lazy var userChangeOptionDataManager = UserChangeOptionDataManager()
    
    init() {
        
        loadUserData()
        //        key = "MtwFLkIHlHWZXwRsBVFHqYL141455244"
        
        userChangeOptionDataManager.delegate = self
        
        vkAuthService.delegate = self
        vkAuthService.isPresentedInProfileView = true
        
    }
    
}

//MARK: - Hide Keyboarf

extension ProfileViewModel{
    
    func hideKeyboard(){
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
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
            
            autoVK = data["user"]["auto_vk"].stringValue
            autoOK = data["user"]["auto_ok"].stringValue
            
            vkExp = data["user"]["vk_exp"].stringValue
            okExp = data["user"]["ok_exp"].stringValue
            
        }
        
    }
    
    func didFailGettingGetProfileDataWithError(error: String) {
        print("Error with GetProfileDataManager ")
    }
    
}

//MARK: - UserChangeOptionDataManagerDelegate

extension ProfileViewModel : UserChangeOptionDataManagerDelegate{
    
    func changeUserOption(){
        
        userChangeOptionDataManager.getUserChangeOptionData(key: key, infoType: (customAlertTitle == "Имя" ? 1 : 2), newValue: customAlertTextFieldText)
        
    }
    
    func didGetUserChangeOptionData(data: JSON) {
        
        DispatchQueue.main.async {
            
            if data["result"].intValue == 1 {
                
                self.getProfileData()
                
                self.isCustomAlertShown = false
                
                self.customAlertTextFieldText = ""
                
            }
            
        }
        
    }
    
    func didFailGettingUserChangeOptionDataWithError(error: String) {
        print("Error with UserChangeOptionDataManager: \(error)")
    }
    
}

//MARK: - UserChangePassDataManagerDelegate

extension ProfileViewModel : UserChangePassDataManagerDelegate{
    
    func changePass(){
        
        if confirmPassText == newPassText{
            
            UserChangePassDataManager(delegate: self).getUserChangePassData(key: key, oldPass: oldPassText, newPass: newPassText)
            
        }
        
    }
    
    func didGetUserChangePassData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1 {
                
                oldPassText = ""
                newPassText = ""
                confirmPassText = ""
                
                isPassAlertShown = false
                
            }
            
        }
        
    }
    
    func didFailGettingUserChangePassDataWithError(error: String) {
        print("Error with UserChangePassDataManager : \(error)")
    }
    
}

//MARK: - Vk Stuff

extension ProfileViewModel : VKAuthServiceDelegate{
    
    func vkAuthServiceShouldShow(viewController: UIViewController) {
        
        //Presenting VK View Controller
        SceneDelegate.shared().window?.rootViewController?.present(viewController, animated: true, completion: nil)
        
    }
    
    func vkAuthServiceSignIn() {
        
        guard let userId = vkAuthService.userId, let _ = vkAuthService.token else {return}
        
        AssignVkToAppIDDataManager(delegate: self).getAssignVkToAppIDData(key: key, vkId: userId, appId: vkAuthService.appId)
        
    }
    
    func vkAuthServiceSignInDidFail() {
        print("Failed VK Sign In")
    }
    
}

//MARK: - Vigruzka

extension ProfileViewModel : AssignVkToAppIDDataManagerDelegate, SaveVkInfoDataManagerDelegate{
    
    func addVkVigruzka(){
        
        vkAuthService.wakeUpSession()
        
    }
    
    func didGetAssignVkToAppIDData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                SaveVkInfoDataManager(delegate: self).getSaveVkInfoData(key: key, fieldId: "1", value: vkAuthService.userId!)
                
                SaveVkInfoDataManager(delegate: self).getSaveVkInfoData(key: key, fieldId: "2", value: vkAuthService.token!)
                
                SaveVkInfoDataManager(delegate: self).getSaveVkInfoData(key: key, fieldId: "3", value: email)
                
                getProfileData()
                
            }
            
        }
        
    }
    
    func didFailGettingAssignVkToAppIDDataWithError(error: String) {
        print("Error with AssignVkToAppIDDataManager : \(error)")
    }
    
    func didGetSaveVkInfoData(data: JSON) {
        
        DispatchQueue.main.async {
            
            
            
        }
        
    }
    
    func didFailGettingSaveVkInfoDataWithError(error: String) {
        print("Error with SaveVkInfoDataManager : \(error)")
    }
    
}
//MARK: - Data Manipulation Methods

extension ProfileViewModel {
    
    func loadUserData (){
        
        let userData = realm.objects(UserData.self)
        
        if let userDataObject = userData.first{
            
            key = userDataObject.key
            
            settings = userDataObject.settings
            
        }
        
    }
    
}
