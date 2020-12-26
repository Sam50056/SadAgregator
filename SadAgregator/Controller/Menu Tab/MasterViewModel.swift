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
    
    @Published var currentStepId : Int?
    @Published var previousStepId = ""
    @Published var nextStepId : String?
    
    @Published var currentViewData : JSON?
    @Published var currentViewType : String?
    
    lazy var getStepDataManager = GetStepDataManager()
    lazy var setSimpleReqDataManager = SetSimpleReqDataManager()
    
    @Published var answers = [SimpleReqAnswer]()
    
    init() {
        
        //        loadUserData()
        key = "MtwFLkIHlHWZXwRsBVFHqYL141455244"
        
        getStepDataManager.delegate = self
        setSimpleReqDataManager.delegate = self
        
    }
    
}

//MARK: - SetUp for Views

extension MasterViewModel{
    
    func setUpForSimpleReq(){
        
        answers.removeAll()
        
        for answer in currentViewData!["ansqers"].arrayValue{
            
            answers.append(SimpleReqAnswer(id: answer["id"].intValue, capt: answer["capt"].stringValue, hint: answer["hint"].stringValue))
            
        }
        
    }
    
}

//MARK: - GetStepDataManager

extension MasterViewModel : GetStepDataManagerDelegate{
    
    func getStepData(){
        
        getStepDataManager.getGetStepData(key: key, step: nextStepId ?? "")
        
    }
    
    func didGetGetStepData(data: JSON) {
        
        DispatchQueue.main.async{ [self] in
            
            currentViewType = data["type"].string
            
            currentViewData = data
            
            currentStepId = data["step_id"].int
            previousStepId = data["back_step_id"].stringValue
            
            if currentViewType == "simple_req"{
                setUpForSimpleReq()
            }
            
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

//MARK: - SetSimpleReqDataManager

extension MasterViewModel : SetSimpleReqDataManagerDelegate{
    
    func selectSimpleReqViewAnswer(id : Int){
        
        setSimpleReqDataManager.getSetSimpleReqData(key: key, stepId: currentStepId!, sellId: id)
        
    }
    
    func didGetSetSimpleReqData(data: JSON) {
        
        DispatchQueue.main.async{ [self] in
            
            if let nextStepId = data["next_step_id"].string {
                
                self.nextStepId = nextStepId
                
                getStepDataManager.getGetStepData(key: key, step: nextStepId)
                
            }
            
        }
        
    }
    
    func didFailGettingSetSimpleReqDataWithError(error: String) {
        print("Error with SetSimpleReqDataManager: \(error)")
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
