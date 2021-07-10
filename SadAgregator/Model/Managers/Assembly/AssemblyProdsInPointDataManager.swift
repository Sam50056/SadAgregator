//
//  AssemblyProdsInPointDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 10.07.2021.
//

import Foundation
import SwiftyJSON

protocol AssemblyProdsInPointDataManagerDelegate {
    func didGetAssemblyProdsInPointData(data : JSON)
    func didFailGettingAssemblyProdsInPointDataWithError(error : String)
}

struct AssemblyProdsInPointDataManager {
    
    var delegate : AssemblyProdsInPointDataManagerDelegate?
    
    func getAssemblyProdsInPointData(key : String , pointId : String , helperId : String , status : String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_assembly.ProdsInPoint?AKey=\(key)&APointID=\(pointId)&APage=\(page)&AHelperID=\(helperId)&AStatus=\(status)"
        
        print("URLString for AssemblyProdsInPointDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingAssemblyProdsInPointDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingAssemblyProdsInPointDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetAssemblyProdsInPointData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
