//
//  AuthView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 11.12.2020.
//

import SwiftUI


struct AuthView: View {
    
    var key : String
    
    @Binding var isPresented : Bool
    
    @Binding var isLogged : Bool
    
    @State var isModalPresented : Bool = true
    
    @State var showLogin : Bool
    
    var body: some View {
        
        if showLogin{
            LoginView(key: key, isPresented: $isPresented, shouldShowLogin: $showLogin, isLogged: $isLogged)
        }else{
            RegView(key: key, isPresented: $isPresented,shouldShowLogin: $showLogin, isLogged: $isLogged)
        }
        
    }
    
}

