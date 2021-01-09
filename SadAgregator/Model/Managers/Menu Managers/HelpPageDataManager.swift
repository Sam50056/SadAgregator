//
//  HelpPageDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 09.01.2021.
//

import Foundation
import SwiftyJSON

protocol HelpPageDataManagerDelegate {
    func didGetHelpPageData(data : JSON)
    func didFailGettingHelpPageData(error : String)
}

struct HelpPageDataManager {
    
    var delegate : HelpPageDataManagerDelegate?
    
    func getHelpPageData(key : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_utils.HelpPage?AKey=\(key)"
        
        print("URLString for HelpPageDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingHelpPageData(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingHelpPageData(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetHelpPageData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
