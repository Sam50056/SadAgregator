//
//  VkAuthService.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 02.01.2021.
//

import Foundation
import VK_ios_sdk

protocol AuthServiceDelegate : class{
    func authServiceShouldShow(viewController : UIViewController)
    func authServiceSignIn()
    func authServiceSignInDidFail()
}

class AuthService : NSObject ,  VKSdkDelegate , VKSdkUIDelegate{
    
    private let appId = "7547797"
    private let vkSdk : VKSdk
    
    weak var delegate : AuthServiceDelegate?
    
    var token : String?{
        return VKSdk.accessToken()?.accessToken
    }
    
    override init() {
        
        vkSdk = VKSdk.initialize(withAppId: appId)
        
        super.init()
        
        print("VKSdk.initialize")
        
        vkSdk.register(self)
        vkSdk.uiDelegate = self
    }
    
    func wakeUpSession() {
        
        let scope = ["offline"]
        
        VKSdk.wakeUpSession(scope) { (state, error) in
            
            switch state {
            
            case .initialized:
                print("Initialized")
                VKSdk.authorize(scope)
            case .authorized:
                print("Authorized")
            default:
                fatalError(error!.localizedDescription)
                
            }
            
        }
        
    }
    
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        print(#function)
        if result.token != nil {
            delegate?.authServiceSignIn()
        }
    }
    
    func vkSdkUserAuthorizationFailed() {
        print(#function)
        delegate?.authServiceSignInDidFail()
    }
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        print(#function)
        delegate?.authServiceShouldShow(viewController: controller)
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        print(#function)
    }
    
}

