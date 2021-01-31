//
//  GetForExportDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 31.01.2021.
//

import Foundation
import SwiftyJSON

protocol GetForExportDataManagerDelegate {
    func didGetGetForExportData(data : JSON)
    func didFailGettingGetForExportDataWithError(error : String)
}

struct GetForExportDataManager {
    
    var delegate : GetForExportDataManagerDelegate?
    
    func getGetForExportData(key : String , postId : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_intf.GetForExport?AKey=\(key)&APostID=\(postId)"
        
        print("URLString for GetForExportDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingGetForExportDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingGetForExportDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingGetForExportDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetGetForExportData(data: jsonAnswer)
            
        }
        
        task.resume()
        
        
    }
    
}
