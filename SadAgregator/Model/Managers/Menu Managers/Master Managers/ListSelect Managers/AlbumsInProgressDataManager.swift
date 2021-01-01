//
//  AlbumsInProgressDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 29.12.2020.
//

import Foundation
import SwiftyJSON

protocol AlbumsInProgressDataManagerDelegate {
    func didGetAlbumsInProgressData(data : JSON)
    func didFailGettingAlbumsInProgressDataWithError(error : String)
}

struct AlbumsInProgressDataManager {
    
    var delegate : AlbumsInProgressDataManagerDelegate?
    
    func getAlbumsInProgressData(key : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_assist.AlbumsInProgress?AKey=\(key)"
        
        print("URLString for AlbumsInProgressDataManager : \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingAlbumsInProgressDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingAlbumsInProgressDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingAlbumsInProgressDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetAlbumsInProgressData(data: jsonAnswer)
        }
        
        task.resume()
        
        
    }
    
}
