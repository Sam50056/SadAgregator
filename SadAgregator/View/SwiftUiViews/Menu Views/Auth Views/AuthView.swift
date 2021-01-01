//
//  AuthView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 11.12.2020.
//

import SwiftUI


struct AuthView: View {
    
    @State var showLogin : Bool
    
    var body: some View {
        
        if showLogin{
            LoginView(shouldShowLogin: $showLogin)
        }else{
            RegView(shouldShowLogin: $showLogin)
        }
        
    }
    
}

