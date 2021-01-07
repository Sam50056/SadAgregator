//
//  MenuViewModel.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 12.12.2020.
//

import Foundation
import SwiftyJSON
import RealmSwift

class MenuViewModel : ObservableObject{
    
    let realm = try! Realm()
    
    let vkAuthService = VKAuthService()
    
    @Published var key = "" 
    
    @Published var isLogged = false
    @Published var name = ""
    @Published var code = ""
    @Published var lkVends = ""
    @Published var lkPosts = ""
    
    @Published var showModalLogIn = false
    @Published var showModalReg = false
    
    @Published var showProfile = false
    
    @Published var showFavoriteVends = false
    
    @Published var showMaster = false
    
    @Published var showAddPointRequestView = false
    
    init() {
        
        loadUserData()
        
        vkAuthService.delegate = self
    }
    
}

//MARK: - CheckKeysDataManagerDelegate

extension MenuViewModel : CheckKeysDataManagerDelegate{
    
    func updateData() {
        
        if isLogged{
            
            if let key = getUserDataObject()?.key{
                
                CheckKeysDataManager(delegate: self).getKeysData(key: key)
                
            }
            
        }
        
    }
    
    func didGetCheckKeysData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if let safeKey = data["key"].string {
                
                let userDataObject = UserData()
                
                let name = data["name"].stringValue
                let code = data["code"].stringValue
                
                let lkVends = data["lk_vends"].stringValue
                let lkPosts = data["lk_posts"].stringValue
                
                userDataObject.name = name
                userDataObject.code = code
                
                userDataObject.isLogged = true
                
                userDataObject.key = safeKey
                
                userDataObject.lkPosts = lkPosts
                userDataObject.lkVends = lkVends
                
                deleteAllDataFromDB()
                
                do{
                    try self.realm.write{
                        self.realm.add(userDataObject)
                    }
                }catch{
                    print("Error saving data to realm , \(error.localizedDescription)")
                }
                
                loadUserData()
                
            }
            
        }
        
    }
    
    func didFailGettingCheckKeysData(error: String) {
        print("Error with CheckKeysDataManager: \(error)")
    }
    
}

//MARK: - VKAuthServiceDelegate

extension MenuViewModel : VKAuthServiceDelegate{
    
    func vkAuth(){
        
        vkAuthService.wakeUpSession()
        
    }
    
    func vkAuthServiceShouldShow(viewController: UIViewController) {
        
        //Presenting VK View Controller
        SceneDelegate.shared().window?.rootViewController?.present(viewController, animated: true, completion: nil)
        
    }
    
    func vkAuthServiceSignIn() {
        print("Successfully Signed via VK")
        
        if let safeVkToken = vkAuthService.token{
            
            AuthSocialDataManager(delegate: self).getGetAuthSocialData(social: "VK", token: safeVkToken, key: key)
            
        }
    }
    
    func vkAuthServiceSignInDidFail() {
        print("Failed VK Sign In")
    }
    
    
}

//MARK: - AuthSocialDataManagerDelegate

extension MenuViewModel : AuthSocialDataManagerDelegate{
    
    func didGetAuthSocialData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            guard let newKey = data["token"].string else {return}
            
            showModalLogIn = false
            showModalReg = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                if let userDataObject = getUserDataObject(){
                    
                    try! realm.write{
                        userDataObject.key = newKey
                    }
                    
                }
                
                isLogged = true
                
                updateData()
                
            }
            
        }
        
    }
    
    func didFailGettingAuthSocialDataWithError(error: String) {
        print("Error with AuthSocialDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension MenuViewModel {
    
    func loadUserData (){
        
        if let userDataObject = getUserDataObject(){
            
            key = userDataObject.key
            
            isLogged = userDataObject.isLogged
            
            name = userDataObject.name
            
            code = userDataObject.code
            
            lkVends = userDataObject.lkVends
            lkPosts = userDataObject.lkPosts
            
        }
        
    }
    
    func getUserDataObject () -> UserData?{
        
        let userData = realm.objects(UserData.self)
        
        if let userDataObject = userData.first{
            return userDataObject
        }
        
        return nil
    }
    
    func deleteAllDataFromDB(){
        
        //Deleting everything from DB
        do{
            
            try realm.write{
                realm.deleteAll()
            }
            
        }catch{
            print("Error with deleting all data from Realm , \(error) ERROR DELETING REALM")
        }
        
    }
    
}
