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
    
    @Published var items = [Item]()
    
    var thisSegmentId : String?
    
    var key = ""
    
    private var assemblyPointsInSegmentDataManager = AssemblyPointsInSegmentDataManager()
    
    init(){
        assemblyPointsInSegmentDataManager.delegate = self
    }
    
}

//MARK: - Functions

extension PointsInSborkaSegmentViewModel{
    
    func update(){
        
        guard let thisSegmentId = thisSegmentId else {return}
        
        assemblyPointsInSegmentDataManager.getAssemblyPointsInSegmentData(key: key, segmentId: thisSegmentId, status: "", helperId: "", page: 1)
        
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
