//
//  SearchListWorkDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 28.12.2020.
//

import Foundation
import SwiftyJSON

protocol SearchListWorkDataManagerDelegate {
    func didGetSearchListWorkData(data : JSON)
    func didFailGettingSearchListWorkDataWithError(error : String)
}

struct SearchListWorkDataManager {
    
    var delegate : SearchListWorkDataManagerDelegate?
    
    func getSearchListWorkData(key: String , stepId : String , query : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_assist.Srch_ListWork?AKey=\(key)&AStep=\(stepId)&AQuery=\(query)"
        
        print("URLString for SearchListWorkDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingSearchListWorkDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingSearchListWorkDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetSearchListWorkData(data: jsonAnswer)
            
        }
        
        task.resume()
        
        
    }
    
}
