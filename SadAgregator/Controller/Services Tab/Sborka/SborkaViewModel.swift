//
//  SborkaViewModel.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 28.06.2021.
//

import Foundation
import SwiftyJSON
import SwiftUI
import RealmSwift

class SborkaViewModel : ObservableObject{
    
    private let realm = try! Realm()
    
    @Published var screenData : JSON?
    
    @Published var items = [Item]()
    
    @Published var showNoItemsView = false
    @Published var noItemsViewText = "Нет элементов для отображения"
    @Published var showNoItemsViewButton = false
    
    @Published var helpers = [Helper]()
    
    @Published var navBarTitle = "Сборка"
    
    @Published var showPointsView = false
    
    @Published var showHelperListSheet = false
    
    @Published var showShowingMySborkaAlertView = false
    
    @Published var showAlert = false
    var showSimpleAlert = false
    var alertTitle = ""
    var alertMessage : String? = nil
    var alertButtonText = "Да"
    
    @Published var showAlertInHelperView = false
    var showSimpleAlertInHelperView = true
    var alertInHelperViewTitle = "Помощники не участвуют в сборке"
    var alertInHelperViewMessage : String? = nil
    var alertInHelperViewButtonText = "Ок"
    
    @Published var menuSortIndex : Int = 0{
        didSet{
            changeStatus(to: menuSortIndex != 3 ? "\(menuSortIndex)" : "")
        }
    }
    
    var selectedByLongPressSegment : Item? = nil
    
    var givenHelperId : String?
    
    var shouldShowSmotretOtSebyaInHelperView : Bool {
        !helpers.isEmpty && selectedByLongPressSegment == nil
    }
    
    var key = ""
    
    @Published var thisSegIndex : Int?
    
    var status : String = "0"
    var helperID : String = ""
    
    private var assemblySegmentsInAssemblyDataManager = AssemblySegmentsInAssemblyDataManager()
    private var assemblyGetHelpersDataManager = AssemblyGetHelpersDataManager()
    private var assemblyGetHelpersInAssemblyDataManager = AssemblyGetHelpersInAssemblyDataManager()
    
    lazy var pointsInSegmentsView = PointsInSborkaSegmentView()
    
    init() {
        
        loadUserData()
        
        assemblySegmentsInAssemblyDataManager.delegate = self
        assemblyGetHelpersDataManager.delegate = self
        assemblyGetHelpersInAssemblyDataManager.delegate = self
        
    }
    
}

//MARK: - Functions

extension SborkaViewModel{
    
    func updateSegments(parent : String = ""){
        
        if parent.isEmpty{
            items.removeAll()
            thisSegIndex = nil
        }
        
        screenData = nil
        
        assemblySegmentsInAssemblyDataManager.getAssemblySegmentsInAssemblyData(key: key, parentSegment: parent, status: status, helperId: helperID)
        
    }
    
    func getHelpers(inSborka : Bool = false){
        
        if inSborka{
            assemblyGetHelpersInAssemblyDataManager.getAssemblyGetHelpersInAssemblyData(key: key)
        }else{
            assemblyGetHelpersDataManager.getAssemblyGetHelpersData(key: key)
        }
        
    }
    
    func giveSegmentTo(_ helper : String){
        
        AssemblyMoveToHelperDataManager().getAssemblyMoveToHelperData(key: key, helper: helper, segment: selectedByLongPressSegment!.segId) { data, error in
            
            DispatchQueue.main.async {
                
                if let error = error , data == nil {
                    print("Error with AssemblyMoveToHelperDataManager : \(error)")
                    return
                }
                
                if data!["result"].intValue == 1{
                    
                    //Show an alert demonstrating given tovar count with option to cancel the action
                    
                    self.givenHelperId = helper
                    
                    let count = data!["cnt"].stringValue
                    
                    self.alertInHelperViewTitle = "Передано товаров: \(count) шт."
                    self.alertInHelperViewMessage = nil
                    self.alertInHelperViewButtonText = "Ок"
                    self.showSimpleAlertInHelperView = false
                    self.showAlertInHelperView = true
                    
                }
                
            }
            
        }
        
    }
    
    func takeSegmentFrom(_ helper : String , isInHelperView : Bool = false){
        
        AssemblyRemoveFromHelperDataManager().getAssemblyRemoveFromHelperData(key: key, helper: helper, segment: selectedByLongPressSegment!.segId) { data, error in
            
            DispatchQueue.main.async {
                
                if let error = error , data == nil {
                    print("Error with AssemblyRemoveFromHelperDataManager : \(error)")
                    return
                }
                
                if data!["result"].intValue == 1{
                    
                    let count = data!["cnt"].stringValue
                    
                    if isInHelperView{
                        
                        if !self.showSimpleAlertInHelperView{
                            
                            self.showHelperListSheet = false
                            
                            self.updateSegments()
                            
                            self.selectedByLongPressSegment = nil
                            
                        }
                        
                    }else{
                        
                        self.alertTitle = "Перенесено на себя товаров: \(count) шт."
                        self.alertMessage = nil
                        self.alertButtonText = "Ок"
                        
                        self.showSimpleAlert = true
                        self.showAlert = true
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func closeTabWithParentIndex(_ index : Int){
        
        var childrenCount = 0
        
        for i in index..<items.count{
            
            if items[i].isOpened{
                
                childrenCount += items[i].childrenCount
                
            }
            
        }
        
        //        print("Children count : \(childrenCount)")
        
        items.removeSubrange(index + 1...index+childrenCount)
        
    }
    
    func changeStatus(to newStatus : String){
        
        withAnimation {
            
            status = newStatus
            
            updateSegments()
            
        }
        
    }
    
    func smotretOtSebya() {
        
        navBarTitle = "Сборка"
        helperID = ""
        updateSegments()
        
    }
    
}

//MARK: - Item

extension SborkaViewModel{
    
    struct Item: Identifiable {
        let id = UUID()
        let segId : String
        let title: String
        let title2 : String
        let title3 : String
        var canGoForDot : Bool
        var parentsCount : Int = 0
        var isOpened = false
        var childrenCount : Int = 0
    }
    
    struct Helper : Identifiable{
        
        var id : String
        var capt : String
        
    }
    
}

//MARK: - AssemblySegmentsInAssemblyDataManagerDelegate

extension SborkaViewModel : AssemblySegmentsInAssemblyDataManagerDelegate{
    
    func didGetAssemblySegmentsInAssemblyData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            screenData = data
            
            if data["result"].intValue == 1{
                
                let jsonItems = data["segments"].arrayValue
                
                if let segIndex = thisSegIndex{
                    
                    items[segIndex].childrenCount = jsonItems.count
                    
                    var insertsCount = 0
                    
                    jsonItems.forEach { jsonItem in
                        
                        var newItem = Item(segId: jsonItem["seg_id"].stringValue, title: jsonItem["seg_name"].stringValue, title2: jsonItem["cnt"].stringValue , title3: jsonItem["summ"].stringValue, canGoForDot: data["max_dept"].stringValue == "1" ? true : false)
                        
                        newItem.parentsCount = 1 + items[segIndex].parentsCount
                        
                        withAnimation(Animation.spring()){
                            items.insert(newItem, at: segIndex + 1 + insertsCount)
                        }
                        
                        insertsCount += 1
                        
                    }
                    
                }else{
                    
                    var newItems = [Item]()
                    
                    jsonItems.forEach { jsonItem in
                        newItems.append(Item(segId: jsonItem["seg_id"].stringValue, title: jsonItem["seg_name"].stringValue, title2: jsonItem["cnt"].stringValue , title3: jsonItem["summ"].stringValue, canGoForDot: data["max_dept"].stringValue == "1" ? true : false))
                    }
                    
                    items = newItems
                    
                }
                
                showNoItemsView = items.isEmpty && screenData != nil
                
                if helperID != "" , items.isEmpty{
                    
                    helperID = ""
                    smotretOtSebya()
                    
                    withAnimation(.spring()){
                        
                        showShowingMySborkaAlertView = true
                        
                        let _ = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] timer in
                            withAnimation(.spring()){
                                self?.showShowingMySborkaAlertView = false
                            }
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func didFailGettingAssemblySegmentsInAssemblyDataWithError(error: String) {
        print("Error with AssemblySegmentsInAssemblyDataManager : \(error)")
    }
    
}

//MARK: - AssemblyGetHelpersDataManager

extension SborkaViewModel : AssemblyGetHelpersDataManagerDelegate{
    
    func getAssemblyGetHelpersData(data: JSON) {
        
        DispatchQueue.main.async {
            
            if data["result"].intValue == 1{
                
                let jsonHelpers = data["helpers"].arrayValue
                
                self.helpers = jsonHelpers.map { jsonHelper in
                    Helper(id: jsonHelper["hl_id"].stringValue, capt: jsonHelper["capt"].stringValue)
                }
                
                self.showHelperListSheet = true
                
            }
            
        }
        
    }
    
    func getAssemblyGetHelpersDataWithError(error: String) {
        print("Error with AssemblyGetHelpersDataManager : \(error)")
    }
    
}

//MARK: - AssemblyGetHelpersInAssemblyDataManager

extension SborkaViewModel : AssemblyGetHelpersInAssemblyDataManagerDelegate{
    
    func didGetAssemblyGetHelpersInAssemblyData(data: JSON) {
        
        DispatchQueue.main.async {
            
            if data["result"].intValue == 1{
                
                let jsonHelpers = data["helpers"].arrayValue
                
                self.helpers = jsonHelpers.map { jsonHelper in
                    Helper(id: jsonHelper["hl_id"].stringValue, capt: jsonHelper["capt"].stringValue)
                }
                
                self.showHelperListSheet = true
                
                //Showing alert that there are no helpers out there
                if self.helpers.isEmpty{
                    
                    self.alertInHelperViewTitle = "Помощники не участвуют в сборке"
                    self.alertInHelperViewMessage = nil
                    self.alertInHelperViewButtonText = "Ок"
                    self.showSimpleAlertInHelperView = true
                    self.showAlertInHelperView = true
                    
                }
                
            }
            
        }
        
    }
    
    func didFailGettingAssemblyGetHelpersInAssemblyDataWithError(error: String) {
        print("Error with AssemblyGetHelpersInAssemblyDataManager : \(error)")
    }
}

//MARK: - Data Manipulation Methods

extension SborkaViewModel {
    
    func loadUserData (){
        
        if let userDataObject = getUserDataObject(){
            
            key = userDataObject.key
            
        }
        
    }
    
    func getUserDataObject () -> UserData?{
        
        let userData = realm.objects(UserData.self)
        
        if let userDataObject = userData.first{
            return userDataObject
        }
        
        return nil
    }

}
