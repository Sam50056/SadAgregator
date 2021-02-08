//
//  SignInWithApple.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 08.02.2021.
//

import SwiftUI
import AuthenticationServices


final class SignInWithApple: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        
        return ASAuthorizationAppleIDButton()
    }
    
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
    }
    
}
