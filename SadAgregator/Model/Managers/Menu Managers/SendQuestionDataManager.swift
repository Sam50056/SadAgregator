//
//  SendQuestionDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 09.01.2021.
//

import Foundation
import SwiftyJSON

protocol SendQuestionDataManagerDelegate{
    func didGetSendQuestionData(data : JSON)
    func didFailGettingSendQuestionDataWithError(error : String)
}

struct SendQuestionDataManager {
    
    var delegate : SendQuestionDataManagerDelegate?
    
    func getSendQuestionData(key : String , email : String , question : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_utils.SendQuestion?AKey=\(key)&AEMail=\(email)&AQuestion=\(question)"
        
        print("URLString for SendQuestionDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingSendQuestionDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingSendQuestionDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetSendQuestionData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
