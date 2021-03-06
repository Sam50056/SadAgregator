//
//  MenuViewModel.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 12.12.2020.
//

import Foundation
import SwiftyJSON
import RealmSwift
import ok_ios_sdk
import AuthenticationServices

class MenuViewModel : ObservableObject{
    
    let realm = try! Realm()
    
    let vkAuthService = VKAuthService()
    @Published var appleSignInDelegates: SignInWithAppleDelegates! = nil
    
    @Published var key = "" 
    
    @Published var isLogged = false
    @Published var name = ""
    @Published var code = ""
    @Published var lkVends = ""
    @Published var lkPosts = ""
    
    @Published var showModalLogIn = false
    @Published var showModalReg = false
    
    @Published var showFavoriteVends = false
    
    @Published var showAddPointRequestView = false
    
    @Published var showSendQuestionView = false
    
    @Published var showHelpView = false
    
    @Published var showAlert = false
    
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
                
                if data["anonym"].stringValue == "0"{
                    
                    let name = data["name"].stringValue
                    let code = data["code"].stringValue
                    
                    let lkVends = data["lk_vends"].stringValue
                    let lkPosts = data["lk_posts"].stringValue
                    
                    userDataObject.name = name
                    userDataObject.code = code
                    
                    userDataObject.isLogged = true
                    
                    userDataObject.lkPosts = lkPosts
                    userDataObject.lkVends = lkVends
                    
                    userDataObject.settings = data["settings"].stringValue
                    
                }else{
                    isLogged = false
                }
                
                userDataObject.exportType = data["export"]["type"].stringValue
                userDataObject.exportFast = data["export"]["fast"].stringValue
                
                userDataObject.imageHashSearch = data["img_hash_srch"].stringValue
                userDataObject.imageHashServer = data["img_hash_srv"].stringValue
                
                userDataObject.key = safeKey
                
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

//MARK: - Login

extension MenuViewModel{
    
    func login(newKey : String){
        
        showModalLogIn = false
        showModalReg = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            
            if let userDataObject = getUserDataObject(){
                
                try! realm.write{
                    userDataObject.key = newKey
                }
                
                loadUserData()
                
            }
            
            isLogged = true
            
            updateData()
            
        }
        
    }
    
}

//MARK: - Apple Login

extension MenuViewModel : SignInWIthAppleIdDataManagerDelegate{
    
    func showAppleLogin() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        performSignIn(using: [request])
    }
    
    func performSignIn(using requests: [ASAuthorizationRequest]) {
        
        appleSignInDelegates = SignInWithAppleDelegates(window: SceneDelegate.shared().window) { [self] success in
            
            if success {
                
                //Success
                
                if let userId = appleSignInDelegates.user{
                    
                    SignInWIthAppleIdDataManager(delegate: self).getSignInWIthAppleIdData(userId: userId, name: self.appleSignInDelegates.name ?? "")
                    
                }
                
            } else {
                
                //Error
                
                print("Error with Apple Sign In (")
                
            }
            
        }
        
        let controller = ASAuthorizationController(authorizationRequests: requests)
        controller.delegate = appleSignInDelegates
        controller.presentationContextProvider = appleSignInDelegates
        
        controller.performRequests()
    }
    
    //SignInWIthAppleIdDataManagerDelegate
    func didGetSignInWIthAppleIdData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                login(newKey: data["set_key"].stringValue)
                
            }else{
                
                
                
            }
            
        }
        
    }
    
    func didFailGettingSignInWIthAppleIdDataWithError(error: String) {
        print("Error with SignInWIthAppleIdDataManager : \(error)")
    }
    
    
}

//MARK: - OKAuth

extension MenuViewModel{
    
    func okAuth(){
        
        print("OK PRESSED")
        
        OKSDK.clearAuth()
        
        OKSDK.authorize(withPermissions: OKAuthService.permissionsArray) { [self] (result) in
            
            print("OK Token : \(String(describing: OKSDK.currentAccessToken()))")
            
            if let safeOkToken =  OKSDK.currentAccessToken(){
                
                AuthSocialDataManager(delegate: self).getGetAuthSocialData(social: "OK", token: safeOkToken, key: key)
                
            }
            
        } error: { (error) in
            print("Error with OK SDK AUTH : \(String(describing: error?.localizedDescription))")
        }
        
    }
    
}

//MARK: - VKAuthServiceDelegate

extension MenuViewModel : VKAuthServiceDelegate{
    
    func vkAuth(){
        
        vkAuthService.isPresentedInProfileView = false
        vkAuthService.wakeUpSession()
        
    }
    
    func vkAuthServiceShouldShow(viewController: UIViewController) {
        
        guard !vkAuthService.isPresentedInProfileView else {return}
        
        //Presenting VK View Controller
        SceneDelegate.shared().window?.rootViewController?.present(viewController, animated: true, completion: nil)
        
    }
    
    func vkAuthServiceSignIn() {
        
        guard !vkAuthService.isPresentedInProfileView else {return}
        
        print("Successfully Signed via VK")
        
        if let safeVkToken = vkAuthService.token{
            
            AuthSocialDataManager(delegate: self).getGetAuthSocialData(social: "VK", token: safeVkToken, key: key)
            
        }
    }
    
    func vkAuthServiceSignInDidFail() {
        
        guard !vkAuthService.isPresentedInProfileView else {return}
        
        print("Failed VK Sign In")
        
    }
    
    
}

//MARK: - AuthSocialDataManagerDelegate

extension MenuViewModel : AuthSocialDataManagerDelegate{
    
    func didGetAuthSocialData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            guard let newKey = data["token"].string else {
                print("Error with token in AuthSocialDataManager")
                return
            }
            
            login(newKey: newKey)
            
        }
        
    }
    
    func didFailGettingAuthSocialDataWithError(error: String) {
        print("Error with AuthSocialDataManager : \(error)")
    }
    
}

//MARK: - Logout

extension MenuViewModel : DelDeviceDataManagerDelegate{
    
    func logout(){
        
        deleteAllDataFromDB() //Delete the current userDataObject from DB
        
        CheckKeysDataManager(delegate: self).getKeysData(key: nil) // CheckKeysRequest with nil key because it's delete on the above line
        
        guard let unToken = UserDefaults.standard.string(forKey: K.UNToken) else {return}
        
        print("UN Token : \(unToken)")
        
        DelDeviceDataManager(delegate: self).getDelDeviceData(key: key, token: unToken)
        
    }
    
    func didGetDelDeviceData(data: JSON) {
        
        DispatchQueue.main.async {
            
            if data["result"].intValue == 1{
                
                UserDefaults.standard.setValue(nil, forKey: K.UNToken)
                
                print("Token Deleted From Server")
                
            }
            
        }
        
    }
    
    func didFailGettingDelDeviceDataWithError(error: String) {
        print("Error with DelDeviceDataManager : \(error)")
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
