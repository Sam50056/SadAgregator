//
//  SearchImageDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 09.01.2021.
//

import Foundation
import SwiftyJSON

protocol SearchImageDataManagerDelegate {
    func didGetSearchImageData(data : JSON)
    func didFailGettingSearchImageDataWithError(error : String)
}

struct SearchImageDataManager {
    
    var delegate : SearchImageDataManagerDelegate?
    
    func getSearchImageData(urlString : String ,ACRop : String , ANOCrop : String){
        
        let urlString = "\(urlString)?ACrop=\(ACRop)&ANoCrop=\(ANOCrop)"
        
        print("URLString for SearchImageDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingSearchImageDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingSearchImageDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingSearchImageDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.utf8)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetSearchImageData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
