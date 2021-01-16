//
//  VkAuthService.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 02.01.2021.
//

import Foundation
import VK_ios_sdk

protocol VKAuthServiceDelegate{
    func vkAuthServiceShouldShow(viewController : UIViewController)
    func vkAuthServiceSignIn()
    func vkAuthServiceSignInDidFail()
}

class VKAuthService : NSObject ,  VKSdkDelegate , VKSdkUIDelegate{
    
    let appId = "7547797"
    private let vkSdk : VKSdk
    
    var delegate : VKAuthServiceDelegate?
    
    var token : String?{
        return VKSdk.accessToken()?.accessToken
    }
    
    var userId : String?{
        return VKSdk.accessToken()?.userId
    }
    
    var email : String?{
        return VKSdk.accessToken()?.email
    }
    
    var isPresentedInProfileView = false
    
    override init() {
        
        vkSdk = VKSdk.initialize(withAppId: appId)
        
        super.init()
        
        print("VKSdk.initialize")
        
        vkSdk.register(self)
        vkSdk.uiDelegate = self
    }
    
    func wakeUpSession() {
        
        let scope = ["photos","offline", "wall", "groups", "email"]
        
        VKSdk.wakeUpSession(scope) { [delegate](state, error) in
            
            switch state {
            
            case .initialized:
                print("Initialized")
                VKSdk.authorize(scope)
            case .authorized:
                print("Authorized")
                delegate?.vkAuthServiceSignIn()
            default:
                delegate?.vkAuthServiceSignInDidFail()
                
            }
            
        }
        
    }
    
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        print(#function)
        if result.token != nil {
            delegate?.vkAuthServiceSignIn()
        }
    }
    
    func vkSdkUserAuthorizationFailed() {
        print(#function)
        delegate?.vkAuthServiceSignInDidFail()
    }
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        print(#function)
        delegate?.vkAuthServiceShouldShow(viewController: controller)
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        print(#function)
    }
    
}

