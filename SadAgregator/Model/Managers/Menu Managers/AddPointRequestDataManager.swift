//
//  AddPointRequestDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 02.01.2021.
//

import Foundation
import SwiftyJSON

protocol AddPointRequestDataManagerDelegate{
    func didGetAddPointRequestData(data : JSON)
    func didFailGettingAddPointRequestDataWithError(error : String)
}

struct AddPointRequestDataManager {
    
    var delegate : AddPointRequestDataManagerDelegate?
    
    func getAddPointRequestData(key : String , place : String , vkUrl : String , comment : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_utils.AddPointRequest?AKey=&APlace=&AURL=&AComment="
        
        print("URLString for AddPointRequestDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingAddPointRequestDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingAddPointRequestDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetAddPointRequestData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
