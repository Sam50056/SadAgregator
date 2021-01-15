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
    
    func getExportPeersData(key : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_intf.ExportPeers?AKey=\(key)"
        
        print("URLString for ExportPeersDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingExportPeersDataWithError(error: "Wrong URL")
            return
        }
        
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
