//
//  FormDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 13.03.2021.
//

import Foundation
import SwiftyJSON

protocol FormDataManagerDelegate {
    func didGetFormData(data : JSON)
    func didFailGettingFormDataWithError(error : String)
}

struct FormDataManager {
    
    var delegate : FormDataManagerDelegate?
    
    func getFormData(key : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_clients.Form?AKey=\(key)"
        
        print("URLString for FormDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingFormDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingFormDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetFormData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
