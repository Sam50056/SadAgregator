//
//  AuthView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 11.12.2020.
//

import SwiftUI


struct AuthView: View {
    
    @Binding var isPresented : Bool
    
    @State var isModalPresented : Bool = true
    
    @State var showLogin : Bool
    
    var body: some View {
        
        if showLogin{
            LoginView(isPresented: $isPresented, shouldShowLogin: $showLogin)
        }else{
            RegView(isPresented: $isPresented,shouldShowLogin: $showLogin)
        }
        
    }
    
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(isPresented: .constant(false), showLogin: true)
    }
}
