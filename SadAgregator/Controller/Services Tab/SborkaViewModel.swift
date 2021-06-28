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
    
    var key = ""
    
    @Published var thisSegIndex : Int?
    
    var assemblySegmentsInAssemblyDataManager = AssemblySegmentsInAssemblyDataManager()
    
    init() {
        
        assemblySegmentsInAssemblyDataManager.delegate = self
        
    }
    
}

//MARK: - Functions

extension SborkaViewModel{
    
    func updateSegments(parent : String = ""){
        
        assemblySegmentsInAssemblyDataManager.getAssemblySegmentsInAssemblyData(key: key, parentSegment: parent, status: "", helperId: "")
        
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
    
}

//MARK: - Item

struct Item: Identifiable {
    let id = UUID()
    let segId : String
    let title: String
    let title2 : String
    let title3 : String
    var parentsCount : Int = 0
    var isOpened = false
    var childrenCount : Int = 0
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
                        
                        var newItem = Item(segId: jsonItem["seg_id"].stringValue, title: jsonItem["seg_name"].stringValue, title2: jsonItem["cnt"].stringValue , title3: jsonItem["summ"].stringValue)
                        
                        newItem.parentsCount = 1 + items[segIndex].parentsCount
                        
                        withAnimation(Animation.spring()){
                            items.insert(newItem, at: segIndex + 1 + insertsCount)
                        }
                        
                        insertsCount += 1
                        
                    }
                    
                }else{
                    
                    var newItems = [Item]()
                    
                    jsonItems.forEach { jsonItem in
                        newItems.append(Item(segId: jsonItem["seg_id"].stringValue, title: jsonItem["seg_name"].stringValue, title2: jsonItem["cnt"].stringValue , title3: jsonItem["summ"].stringValue))
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
