//
//  PointsInSborkaSegmentViewModel.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 04.07.2021.
//

import Foundation
import SwiftUI
import SwiftyJSON

class PointsInSborkaSegmentViewModel : ObservableObject{
    
    var key = ""
    
    @Published var items = [Item]()
    @Published var helpers = [Helper]()
    
    var thisSegmentId : String?
    
    @Published var showHelperListSheet = false
    
    @Published var showAlert = false
    var alertTitle = ""
    var alertMessage : String? = nil
    var alertButtonText = "Да"
    
    var selectedByLongPressPoint : Item?
    
    var status : String = ""
    var helperID : String = ""
    
    private var assemblyPointsInSegmentDataManager = AssemblyPointsInSegmentDataManager()
    private lazy var assemblyMoveToHelperPointDataManager = AssemblyMoveToHelperPointDataManager()
    private lazy var assemblyGetHelpersDataManager = AssemblyGetHelpersDataManager()
    private lazy var assemblyGetHelpersInAssemblyDataManager = AssemblyGetHelpersInAssemblyDataManager()
    
    init(){
        assemblyPointsInSegmentDataManager.delegate = self
        assemblyGetHelpersDataManager.delegate = self
        assemblyGetHelpersInAssemblyDataManager.delegate = self
    }
    
}

//MARK: - Functions

extension PointsInSborkaSegmentViewModel{
    
    func update(){
        
        guard let thisSegmentId = thisSegmentId else {return}
        
        assemblyPointsInSegmentDataManager.getAssemblyPointsInSegmentData(key: key, segmentId: thisSegmentId, status: status, helperId: helperID, page: 1)
        
    }
    
    func getHelpers(inSborka : Bool = false){
        
        if inSborka{
            assemblyGetHelpersInAssemblyDataManager.getAssemblyGetHelpersInAssemblyData(key: key)
        }else{
            assemblyGetHelpersDataManager.getAssemblyGetHelpersData(key: key)
        }
        
    }
    
    func givePointTo(_ helper : String){
        
        AssemblyMoveToHelperPointDataManager().getAssemblyMoveToHelperPointData(key: key, helper: helper, point: selectedByLongPressPoint!.pointId) { data, error in
            
            DispatchQueue.main.async {
                
                if let error = error , data == nil {
                    print("Error with AssemblyMoveToHelperDataManager : \(error)")
                    return
                }
                
                if data!["result"].intValue == 1{
                    
                    self.showHelperListSheet = false
                    self.update()
                    
                    self.selectedByLongPressPoint = nil
                    
                }
                
            }
            
        }
        
    }
    
    func takePointFrom(_ helper : String){
        
        AssemblyRemoveFromHelperPointDataManager().getAssemblyRemoveFromHelperPointData(key: key, helper: helper, point: selectedByLongPressPoint!.pointId) { data, error in
            
            DispatchQueue.main.async {
                
                if let error = error , data == nil {
                    print("Error with AssemblyRemoveFromHelperPointDataManager : \(error)")
                    return
                }
                
                if data!["result"].intValue == 1{
                    
                    self.update()
                    
                    self.selectedByLongPressPoint = nil
                    
                }
                
            }
            
        }
        
    }
    
    func changeStatus(to newStatus : String){
        
        withAnimation {
            
            status = newStatus
            
            update()
            
        }
        
    }
    
}

//MARK: - Item

extension PointsInSborkaSegmentViewModel{
    
    struct Item: Identifiable {
        let id = UUID()
        let pointId : String
        let capt : String
        let count : String
        let summ : String
    }
    
    struct Helper : Identifiable{
        
        var id : String
        var capt : String
        
    }
    
}

//MARK: - AssemblyPointsInSegmentDataManager

extension PointsInSborkaSegmentViewModel : AssemblyPointsInSegmentDataManagerDelegate{
    
    func didGetAssemblyPointsInSegmentData(data: JSON) {
        
        DispatchQueue.main.async {
            
            if data["result"].intValue == 1{
                
                let jsonItems = data["segment_points"].arrayValue
                
                var newItems = [Item]()
                
                for jsonItem in jsonItems{
                    
                    newItems.append(Item(pointId: jsonItem["point_id"].stringValue, capt: jsonItem["capt"].stringValue, count: jsonItem["cnt"].stringValue, summ: jsonItem["summ"].stringValue))
                    
                }
                
                self.items = newItems
                
            }
            
        }
        
    }
    
    func didFailGettingAssemblyPointsInSegmentDataWithError(error: String) {
        print("Error with AssemblyPointsInSegmentDataManager : \(error)")
    }
    
}


//MARK: - AssemblyGetHelpersDataManager

extension PointsInSborkaSegmentViewModel : AssemblyGetHelpersDataManagerDelegate{
    
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

extension PointsInSborkaSegmentViewModel : AssemblyGetHelpersInAssemblyDataManagerDelegate{
    
    func didGetAssemblyGetHelpersInAssemblyData(data: JSON) {
        
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
    
    func didFailGettingAssemblyGetHelpersInAssemblyDataWithError(error: String) {
        print("Error with AssemblyGetHelpersInAssemblyDataManager : \(error)")
    }
    
}
