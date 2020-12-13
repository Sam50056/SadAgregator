//
//  MenuViewModel.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 12.12.2020.
//

import Foundation
import RealmSwift

class MenuViewModel : ObservableObject{
    
    let realm = try! Realm()
    
    @Published var key = "" 
    
    @Published var isLogged = false
    @Published var name = ""
    @Published var code = ""
    
    @Published var showModalLogIn = false
    @Published var showModalReg = false
    
    init() {
        loadUserData()
    }
    
}

//MARK: - Data Manipulation Methods

extension MenuViewModel {
    
    func loadUserData (){
        
        let userData = realm.objects(UserData.self)
        
        if let userDataObject = userData.first{
            
            key = userDataObject.key
            
            isLogged = userDataObject.isLogged
            
            name = userDataObject.name
            
            code = userDataObject.code
            
        }
        
    }
}
