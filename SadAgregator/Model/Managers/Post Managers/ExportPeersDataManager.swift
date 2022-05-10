//
//  ExportPeersDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 15.01.2021.
//

import Foundation
import SwiftyJSON

protocol ExportPeersDataManagerDelegate{
    func didGetExportPeersData(data : JSON)
    func didFailGettingExportPeersDataWithError(error : String)
}

struct ExportPeersDataManager {
    
    var delegate : ExportPeersDataManagerDelegate?
    
    func getExportPeersData(domain : String , key : String , query : String = "" , page : Int = 1){
        
        let urlString = "https://\(domain != "" ? domain : "agrapi.tk-sad.ru")/agr_intf.ExportPeersv2?AKey=\(key)&AQuery=\(query)&APage=\(page)"
        
        print("URLString for ExportPeersDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingExportPeersDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingExportPeersDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetExportPeersData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
