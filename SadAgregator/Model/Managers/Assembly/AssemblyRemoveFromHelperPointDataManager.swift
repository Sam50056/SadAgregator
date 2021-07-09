//
//  AssemblyRemoveFromHelperPointDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 09.07.2021.
//
///agr_assembly.RemoveFromHelperPoint?AKey=&AHepler=&APointID=
import Foundation
import SwiftyJSON

struct AssemblyRemoveFromHelperPointDataManager {
    
    func getAssemblyRemoveFromHelperPointData(key : String , helper : String , point : String , completionHandler: @escaping (JSON?, String?) -> Void){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_assembly.RemoveFromHelperPoint?AKey=\(key)&AHepler=\(helper)&APointID=\(point)"
        
        print("URLString for AssemblyRemoveFromHelperPointDataManager: \(urlString)")
        
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
