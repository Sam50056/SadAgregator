//
//  MasterViewModel.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 26.12.2020.
//

import Foundation
import SwiftyJSON
import RealmSwift

class MasterViewModel : ObservableObject{
    
    let realm = try! Realm()
    
    @Published var key = ""
    
    @Published var shouldShowBackButton = false
    
    @Published var previousStepId = ""
    @Published var nextStepId : Int?
    
    @Published var currentViewData : JSON?
    @Published var currentViewType : String?
    
    lazy var getStepDataManager = GetStepDataManager()
    
    init() {
        
        loadUserData()
        
        getStepDataManager.delegate = self
        
    }
    
}

//MARK: - GetStepDataManagerDelegate

extension MasterViewModel : GetStepDataManagerDelegate{
    
    func getStepData(){
        
        getStepDataManager.getGetStepData(key: key)
        
    }
    
    func didGetGetStepData(data: JSON) {
        
        DispatchQueue.main.async{ [self] in
            
            currentViewType = data["type"].string
            
            nextStepId = data["step_id"].int
            previousStepId = data["back_step_id"].stringValue
            
            currentViewData = data
            
            if previousStepId == "" {
                shouldShowBackButton = false
            }else{
                shouldShowBackButton = true
            }
            
        }
        
    }
    
    func didFailGettingGetStepDataWithError(error: String) {
        print("Error with GetStepDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension MasterViewModel {
    
    func loadUserData (){
        
        let userData = realm.objects(UserData.self)
        
        if let userDataObject = userData.first{
            
            key = userDataObject.key
            
            
        }
        
    }
    
}
