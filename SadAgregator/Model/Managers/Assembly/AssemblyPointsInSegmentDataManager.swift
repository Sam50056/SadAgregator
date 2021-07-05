//
//  AssemblyPointsInSegmentDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 04.07.2021.
//

import Foundation
import SwiftyJSON

protocol AssemblyPointsInSegmentDataManagerDelegate {
    func didGetAssemblyPointsInSegmentData(data : JSON)
    func didFailGettingAssemblyPointsInSegmentDataWithError(error : String)
}

struct AssemblyPointsInSegmentDataManager {
    
    var delegate : AssemblyPointsInSegmentDataManagerDelegate?
    
    func getAssemblyPointsInSegmentData(key : String , segmentId : String , status : String , helperId : String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_assembly.PointsInSegment?AKey=\(key)&ASegmentID=\(segmentId)&AStatus=\(status)&AHelper=\(helperId)&APage=\(page)"
        
        print("URLString for AssemblyPointsInSegmentDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingAssemblyPointsInSegmentDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingAssemblyPointsInSegmentDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetAssemblyPointsInSegmentData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
