//
//  AssemblySetItemStatusDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 13.07.2021.
//

import Foundation
import SwiftyJSON

struct AssemblySetItemStatusDataManager {
    
    func getAssemblySetItemStatusData(key : String , id : String , status : String, completionHandler: @escaping (JSON?, String?) -> Void){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_assembly.SetItemStatus?AKey=\(key)&AItemID=\(id)&AStatus=\(status)"
        
        print("URLString for AssemblySetItemStatusDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                completionHandler(nil, error!.localizedDescription)
                return
            }
            
            guard let data = data else {completionHandler(nil, "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            completionHandler(jsonAnswer,nil)
            
        }
        
        task.resume()
        
    }
    
}
