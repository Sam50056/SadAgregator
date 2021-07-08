//
//  AssemblyGetHelpersDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 08.07.2021.
//

import Foundation
import SwiftyJSON

protocol AssemblyGetHelpersDataManagerDelegate {
    func getAssemblyGetHelpersData(data : JSON)
    func getAssemblyGetHelpersDataWithError(error : String)
}

struct AssemblyGetHelpersDataManager {
    
    var delegate : AssemblyGetHelpersDataManagerDelegate?
    
    func getAssemblyGetHelpersData(key : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_assembly.GetHelpers?AKey=\(key)"
        
        print("URLString for AssemblyGetHelpersDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.getAssemblyGetHelpersDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.getAssemblyGetHelpersDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.getAssemblyGetHelpersData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
