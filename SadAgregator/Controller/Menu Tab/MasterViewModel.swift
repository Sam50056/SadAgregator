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
    
    @Published var shouldShowMaster = false
    
    @Published var shouldShowBackButton = false
    
    @Published var currentStepId : Int?
    @Published var previousStepId = ""
    @Published var nextStepId : String?
    
    @Published var currentViewData : JSON?
    @Published var currentViewType : String?
    
    lazy var getStepDataManager = GetStepDataManager()
    lazy var setSimpleReqDataManager = SetSimpleReqDataManager()
    lazy var setListSelectDataManager = SetListSelectDataManager()
    
    @Published var answers = [SimpleReqAnswer]()
    
    @Published var items = [ListSelectItem]()
    
    init() {
        
        //        loadUserData()
        key = "MtwFLkIHlHWZXwRsBVFHqYL141455244"
        
        getStepDataManager.delegate = self
        setSimpleReqDataManager.delegate = self
        setListSelectDataManager.delegate = self
        
    }
    
}

//MARK: - Back Button

extension MasterViewModel{
    
    func backButtonPressed(){
        
        nextStepId = previousStepId
        
        getStepData()
        
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
    
    func setUpListSelect() {
        
        items.removeAll()
        
        for item in currentViewData!["items"].arrayValue{
            
            items.append(ListSelectItem(id: item["id"].intValue, capt: item["capt"].stringValue, hint: item["hint"].stringValue, button: item["button"].stringValue))
            
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
            }else if currentViewType == "list_select" {
                setUpListSelect()
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
                
                if nextStepId == "-2"{
                    shouldShowMaster = false
                    return
                }
                
                getStepData()
                
            }
            
        }
        
    }
    
    func didFailGettingSetSimpleReqDataWithError(error: String) {
        print("Error with SetSimpleReqDataManager: \(error)")
    }
    
}

//MARK: - SetListSelectDataManager

extension MasterViewModel : SetListSelectDataManagerDelegate{
    
    func selectListSelectViewAnswer(id : Int){
        
        setListSelectDataManager.getSetListSelectData(key: key, stepId: currentStepId!, listId: id)
        
    }
    
    func didGetSetListSelectData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if let nextStepId = data["next_step_id"].string {
                
                self.nextStepId = nextStepId
                
                if nextStepId == "-2"{
                    shouldShowMaster = false
                    return
                }
                
                getStepData()
                
            }
            
        }
        
    }
    
    func didFailGettingSetListSelectDataWithError(error: String) {
        print("Error with SetListSelectDataManager : \(error)")
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
