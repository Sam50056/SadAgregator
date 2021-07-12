//
//  SborkaViewModel.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 28.06.2021.
//

import Foundation
import SwiftyJSON
import SwiftUI

class SborkaViewModel : ObservableObject{
    
    @Published var items = [Item]()
    
    @Published var helpers = [Helper]()
    
    @Published var navBarTitle = "Сборка"
    
    @Published var showPointsView = false
    
    @Published var showHelperListSheet = false
    
    @Published var showAlert = false
    var alertTitle = ""
    var alertMessage : String? = nil
    var alertButtonText = "Да"
    
    @Published var showAlertInHelperView = false
    var alertInHelperViewTitle = "Помощники не участвуют в сборке"
    var alertInHelperViewMessage : String? = nil
    var alertInHelperViewButtonText = "Ок"
    
    var selectedByLongPressSegment : Item?
    
    var key = ""
    
    @Published var thisSegIndex : Int?
    
    var status : String = ""
    var helperID : String = ""
    
    private var assemblySegmentsInAssemblyDataManager = AssemblySegmentsInAssemblyDataManager()
    private var assemblyGetHelpersDataManager = AssemblyGetHelpersDataManager()
    private var assemblyGetHelpersInAssemblyDataManager = AssemblyGetHelpersInAssemblyDataManager()
    
    lazy var pointsInSegmentsView = PointsInSborkaSegmentView()
    
    init() {
        
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
                    
                    self.showHelperListSheet = false
                    self.updateSegments()
                    
                    self.selectedByLongPressSegment = nil
                    
                }
                
            }
            
        }
        
    }
    
    func takeSegmentFrom(_ helper : String){
        
        AssemblyRemoveFromHelperDataManager().getAssemblyRemoveFromHelperData(key: key, helper: helper, segment: selectedByLongPressSegment!.segId) { data, error in
            
            DispatchQueue.main.async {
                
                if let error = error , data == nil {
                    print("Error with AssemblyRemoveFromHelperDataManager : \(error)")
                    return
                }
                
                if data!["result"].intValue == 1{
                    
                    self.updateSegments()
                    
                    self.selectedByLongPressSegment = nil
                    
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
                    
                    self.showAlertInHelperView = true
                    
                }
                
            }
            
        }
        
    }
    
    func didFailGettingAssemblyGetHelpersInAssemblyDataWithError(error: String) {
        print("Error with AssemblyGetHelpersInAssemblyDataManager : \(error)")
    }
}
