//
//  SignInWithAppleDelegates.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 09.02.2021.
//

import UIKit
import AuthenticationServices
import Contacts

class SignInWithAppleDelegates: NSObject {
    
    private let signInSucceeded: (Bool) -> Void
    private weak var window: UIWindow!
    
    var user : String?
    
    var name : String?
    
    var username : String?
    var password : String?
    
    init(window: UIWindow?, onSignedIn: @escaping (Bool) -> Void) {
        self.window = window
        self.signInSucceeded = onSignedIn
    }
}

extension SignInWithAppleDelegates: ASAuthorizationControllerDelegate {
    
    private func registerNewAccount(credential: ASAuthorizationAppleIDCredential) {
        
        let userId = credential.user
        
        let name = credential.fullName?.givenName
        
        print("USER ID : \(userId)")
        print("USER NAME : \(String(describing: name))")
        
        user = credential.user
        
        print(#function)
        
        self.signInSucceeded(true)
        
    }
    
    private func signInWithExistingAccount(credential: ASAuthorizationAppleIDCredential) {
        
        print(#function)
        
        print("USER ID : \(credential.user)")
        print("USER NAME : \(String(describing: credential.fullName?.givenName))")
        
        user = credential.user
        
        self.signInSucceeded(true)
    }
    
    private func signInWithUserAndPassword(credential: ASPasswordCredential) {
        
        print(#function)
        
        print("USERNAME : \(credential.user)")
        print("USER PASS : \(String(describing: credential.password))")
        
        username = credential.user
        password = credential.password
        
        self.signInSucceeded(true)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
        
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            
            if let _ = appleIdCredential.email, let _ = appleIdCredential.fullName {
                //This means this is the first apple auth because if it wasn't we wouldn't have gotten the email and name
                registerNewAccount(credential: appleIdCredential)
            } else {
                //This means this is not the first apple auth
                signInWithExistingAccount(credential: appleIdCredential)
            }
            
            break
            
        case let passwordCredential as ASPasswordCredential:
            
            signInWithUserAndPassword(credential: passwordCredential)
            
            break
            
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
        print("Error with Apple Sign in : \(error.localizedDescription)")
        
        self.signInSucceeded(false)
        
    }
    
}

extension SignInWithAppleDelegates: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.window
    }
}

