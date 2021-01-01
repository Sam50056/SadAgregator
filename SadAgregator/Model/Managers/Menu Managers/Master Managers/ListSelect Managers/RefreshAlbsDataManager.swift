//
//  RefreshAlbsDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 28.12.2020.
//

import Foundation
import SwiftyJSON

protocol RefreshAlbsDataManagerDelegate {
    func didGetRefreshAlbsData(data : JSON)
    func didFailGettingRefreshAlbsDataWithError(error : String)
}

struct RefreshAlbsDataManager {
    
    var delegate : RefreshAlbsDataManagerDelegate?
    
    func getRefreshAlbsData(key : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_assist.RefreshAlbs?AKey=\(key)"
        
        print("URLString for RefreshAlbsDataManager : \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingRefreshAlbsDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingRefreshAlbsDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingRefreshAlbsDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetRefreshAlbsData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
