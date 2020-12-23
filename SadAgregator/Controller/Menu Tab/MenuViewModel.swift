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
    
    @Published var key = "" 
    
    @Published var isLogged = false
    @Published var name = ""
    @Published var code = ""
    
    @Published var showModalLogIn = false
    @Published var showModalReg = false
    
    @Published var showProfile = false
    
    @Published var showFavoriteVends = false
    
    init() {
        loadUserData()
    }
    
}

//MARK: - CheckKeysDataManagerDelegate

extension MenuViewModel : CheckKeysDataManagerDelegate{
    
    func updateData() {
        
        if isLogged{
            
            CheckKeysDataManager(delegate: self).getKeysData(key: key)
            
        }
        
    }
    
    func didGetCheckKeysData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if let safeKey = data["key"].string {
                
                let userDataObject = UserData()
                
                let name = data["name"].stringValue
                let code = data["code"].stringValue
                
                userDataObject.name = name
                userDataObject.code = code
                
                userDataObject.isLogged = true
                
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
