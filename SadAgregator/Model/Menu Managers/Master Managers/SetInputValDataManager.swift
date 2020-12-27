//
//  SetInputValDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 27.12.2020.
//

import Foundation
import SwiftyJSON

protocol SetInputValDataManagerDelegate {
    func didGetSetInputValData(data : JSON)
    func didFailGettingSetInputValDataWithError(error : String)
}

struct SetInputValDataManager {
    
    var delegate : SetInputValDataManagerDelegate?
    
    func getSetInputValData(key: String , stepId : Int , buttonId : Int ,val : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_assist.Set_InputVAL?AKey=\(key)&AStepID=\(stepId)&AButtonID=\(buttonId)&AVal=\(val)"
        
        print("URLString for GetSearchPageDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingSetInputValDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingSetInputValDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetSetInputValData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
