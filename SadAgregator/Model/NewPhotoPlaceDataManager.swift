//
//  NewPhotoPlaceDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 17.12.2020.
//

import Foundation
import SwiftyJSON

protocol NewPhotoPlaceDataManagerDelegate {
    func didGetNewPhotoPlaceData(data : JSON )
    func didFailGettingNewPhotoPlaceDataWithError(error : String)
}

struct NewPhotoPlaceDataManager {
    
    var delegate : NewPhotoPlaceDataManagerDelegate?
    
    func getNewPhotoPlaceData(key : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_utils.NewPhotoPlace?AKey=\(key)"
        
        print("URLString for VendorLikeDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingNewPhotoPlaceDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingNewPhotoPlaceDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingNewPhotoPlaceDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetNewPhotoPlaceData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}

