//
//  AssemblyGetHelpersInAssemblyDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 10.07.2021.
//

import Foundation
import SwiftyJSON

protocol AssemblyGetHelpersInAssemblyDataManagerDelegate {
    func didGetAssemblyGetHelpersInAssemblyData(data : JSON)
    func didFailGettingAssemblyGetHelpersInAssemblyDataWithError(error : String)
}

struct AssemblyGetHelpersInAssemblyDataManager{
    
    var delegate : AssemblyGetHelpersInAssemblyDataManagerDelegate?
    
    func getAssemblyGetHelpersInAssemblyData(key : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_assembly.GetHelpersInAssembly?AKey=\(key)"
        
        print("URLString for AssemblyGetHelpersInAssemblyDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingAssemblyGetHelpersInAssemblyDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingAssemblyGetHelpersInAssemblyDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetAssemblyGetHelpersInAssemblyData(data: jsonAnswer)
            
        }
        
        task.resume()
        
        
    }
    
}
