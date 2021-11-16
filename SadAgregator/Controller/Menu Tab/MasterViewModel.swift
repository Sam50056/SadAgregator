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
    lazy var setListSelectDataManager = SetListSelectDataManager()
    lazy var setInputValDataManager = SetInputValDataManager()
    lazy var searchListWorkDataManager = SearchListWorkDataManager()
    lazy var refreshAlbsDataManager = RefreshAlbsDataManager()
    lazy var albumsInProgressDataManager = AlbumsInProgressDataManager()
    lazy var getListWorkExtDataManager = GetListWorkExtDataManager()
    lazy var setListWorkDataManager = SetListWorkDataManager()
    
    @Published var answers = [SimpleReqAnswer]()
    
    @Published var items = [ListSelectItem](){
        didSet{
            filteredItems = items
        }
    }
    @Published var filteredItems = [ListSelectItem]()
    @Published var shouldShowAlertInListSelect = false
    @Published var shouldShowAlbomAlertInListSelect = false
    @Published var simpleAlerttextInListSelect = "" 
    @Published var shouldShowAnimationInListSelect = false
    @Published var listSelectTextFieldText = "" {
        didSet{
            
            if listSelectTextFieldText != "" {
                filteredItems = items.filter{$0.capt.lowercased().contains(listSelectTextFieldText.lowercased())}
            }else{
                filteredItems = items
            }
            
        }
    }
    
    @Published var inputValTextFieldText = "" {
        didSet {
            
            guard let currentViewData = currentViewData else {return}
            
            let characterLimit = currentViewData["max_len"].int
            
            if inputValTextFieldText.count > characterLimit ?? 32 && oldValue.count <= characterLimit ?? 32 {
                inputValTextFieldText = oldValue
            }
            
        }
    }
    
    @Published var listWorkData = JSON()
    @Published var list = [ListWorkItem]()
    @Published var list2 = [ListWorkItem]()
    @Published var extButtonTitleCount = 0
    @Published var shouldShowSecondScreenInListWork = false
    @Published var listWorkSearchTextFieldText = ""{
        didSet{
            
            if listWorkSearchTextFieldText == ""{
                searchListWorkDataManager.cancelTask()
                list.removeAll()
            }else{
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
                    
                    getSearchListWorkData()
                    
                }
                
            }
            
        }
    }
    
    init() {
        //        key = "MtwFLkIHlHWZXwRsBVFHqYL141455244"
        
        //Setting Delegates
        
        getStepDataManager.delegate = self
        setSimpleReqDataManager.delegate = self
        setListSelectDataManager.delegate = self
        setInputValDataManager.delegate = self
        searchListWorkDataManager.delegate = self
        refreshAlbsDataManager.delegate = self
        albumsInProgressDataManager.delegate = self
        getListWorkExtDataManager.delegate = self
        setListWorkDataManager.delegate = self
        
    }
    
}

//MARK: - Hide Keyboarf

extension MasterViewModel{
    
    func hideKeyboard(){
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
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
            
            answers.append(SimpleReqAnswer(id: answer["id"].intValue, capt: answer["capt"].stringValue, hint: answer["hint"].stringValue, rec: answer["rec"].intValue))
            
        }
        
    }
    
    func setUpListSelect() {
        
        items.removeAll()
        
        for item in currentViewData!["items"].arrayValue{
            
            items.append(ListSelectItem(id: item["id"].intValue, capt: item["capt"].stringValue, hint: item["hint"].stringValue, button: item["button"].stringValue, rec: item["rec"].intValue))
            
        }
        
    }
    
    func setUpInputVal(){
        
        inputValTextFieldText = currentViewData!["input_val"]["def_val"].stringValue
        
    }
    
    func setUpListWork(data : JSON){
        
        list.removeAll()
        
        for item in data["list"].arrayValue{
            
            list.append(ListWorkItem(id: item["id"].intValue, capt: item["capt"].stringValue, subCapt: item["sub_capt"].stringValue, act: item["act"].stringValue, ext: item["ext"].intValue))
            
        }
        
        if Int(data["ext_list_cnt"].stringValue) != nil{
            extButtonTitleCount = Int(data["ext_list_cnt"].stringValue)!
        }
        
        listWorkData = data
        
    }
    
}

//MARK: - GetStepDataManager

extension MasterViewModel : GetStepDataManagerDelegate{
    
    func getStepData(hideMaster : ( () -> Void)? = nil){
        
        if nextStepId == "-2"{
            
            hideMaster?()
            
            emptyData()
            
        }else{
            
            getStepDataManager.getGetStepData(key: key, step: nextStepId ?? "")
            
        }
        
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
            }else if currentViewType == "input_val"{
                setUpInputVal()
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
            
            if data["result"].intValue == 1 {
                
                if let nextStepId = data["next_step_id"].string {
                    
                    self.nextStepId = nextStepId
                    
                    getStepData()
                    
                }
                
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
            
            if data["result"].intValue == 1 {
                
                if let nextStepId = data["next_step_id"].string {
                    
                    self.nextStepId = nextStepId
                    
                    getStepData()
                    
                }
                
            }else{
                
                if let message = data["msg"].string{
                    
                    shouldShowAlertInListSelect = true
                    simpleAlerttextInListSelect = message
                    shouldShowAlbomAlertInListSelect = false
                    
                }
                
            }
            
        }
        
    }
    
    func didFailGettingSetListSelectDataWithError(error: String) {
        print("Error with SetListSelectDataManager : \(error)")
    }
    
}

//MARK: - RefreshAlbsDataManager

extension MasterViewModel : RefreshAlbsDataManagerDelegate{
    
    func refreshAlbsData(){
        refreshAlbsDataManager.getRefreshAlbsData(key: key)
        shouldShowAnimationInListSelect = true
    }
    
    func didGetRefreshAlbsData(data: JSON) {
        
        DispatchQueue.main.async {
            self.checkAlbumRefreshProgress()
        }
        
    }
    
    func didFailGettingRefreshAlbsDataWithError(error: String) {
        print("Error with RefreshAlbsDataManager : \(error)")
    }
    
}

//MARK: - AlbumsInProgressDataManager

extension MasterViewModel : AlbumsInProgressDataManagerDelegate{
    
    func checkAlbumRefreshProgress(){
        albumsInProgressDataManager.getAlbumsInProgressData(key: key)
    }
    
    func didGetAlbumsInProgressData(data: JSON) {
        
        DispatchQueue.main.async {
            
            if data["result"].intValue == 1{
                
                self.getStepData()
                
                self.shouldShowAnimationInListSelect = false
                
            }else{
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { timer in
                    self.checkAlbumRefreshProgress()
                }
            }
            
        }
        
    }
    
    func didFailGettingAlbumsInProgressDataWithError(error: String) {
        print("Error with AlbumsInProgressDataManager : \(error)")
    }
    
}

//MARK: - SetInputValDataManager

extension MasterViewModel : SetInputValDataManagerDelegate{
    
    func selectInputValViewButton(id : Int){
        
        setInputValDataManager.getSetInputValData(key: key, stepId: currentStepId!, buttonId: id, val: inputValTextFieldText)
        
    }
    
    func didGetSetInputValData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1 {
                
                if let nextStepId = data["next_step_id"].string {
                    
                    self.nextStepId = nextStepId
                    
                    getStepData()
                    
                }
                
            }
            
        }
        
    }
    
    func didFailGettingSetInputValDataWithError(error: String) {
        print("Error with SetInputValDataManager : \(error)")
    }
    
}

//MARK: - SearchListWorkDataManager

extension MasterViewModel : SearchListWorkDataManagerDelegate{
    
    func getSearchListWorkData(){
        
        searchListWorkDataManager.getSearchListWorkData(key: key, stepId: currentStepId!, query: listWorkSearchTextFieldText)
        
    }
    
    func didGetSearchListWorkData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            setUpListWork(data: data)
            
        }
        
    }
    
    func didFailGettingSearchListWorkDataWithError(error: String) {
        print("Error with SearchListWorkDataManager : \(error)")
    }
    
}

//MARK: - GetListWorkExtDataManager

extension MasterViewModel : GetListWorkExtDataManagerDelegate{
    
    func extButtonPressed(){
        
        getListWorkExtDataManager.getGetListWorkExtData(key: key, stepId: currentStepId!)
        
    }
    
    func didGetGetListWorkExtData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            list2.removeAll()
            
            for item in data["list"].arrayValue{
                
                list2.append(ListWorkItem(id: item["id"].intValue, capt: item["capt"].stringValue, subCapt: item["sub_capt"].stringValue, act: item["act"].stringValue, ext: item["ext"].intValue))
                
            }
            
            listWorkData = data
            
        }
        
    }
    
    func didFailGettingGetListWorkExtDataWithError(error: String) {
        print("Error with GetListWorkExtDataManager : \(error)")
    }
    
}

//MARK: - SetListWorkDataManager

extension MasterViewModel : SetListWorkDataManagerDelegate{
    
    func donePressedInListWork(){
        setListWorkDataManager.getSetListWorkData(key: key, stepId: currentStepId!)
    }
    
    func didGetSetListWorkData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1 {
                
                if let nextStepId = data["next_step_id"].string {
                    
                    self.nextStepId = nextStepId
                    
                    getStepData()
                    
                }
                
            }
            
        }
        
    }
    
    func didFailGettingSetListWorkDataWithError(error: String) {
        print("Error with SetListWorkDataManager : \(error)")
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
    
    func emptyData() {
        
        nextStepId = nil
        currentStepId = nil
        currentViewType = nil
        inputValTextFieldText = ""
        listWorkSearchTextFieldText = "" 
        
    }
    
}
