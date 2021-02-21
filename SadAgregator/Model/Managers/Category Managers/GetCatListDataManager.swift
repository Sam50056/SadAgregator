//
//  GetCatListDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 18.02.2021.
//

import Foundation
import SwiftyJSON

protocol GetCatListDataManagerDelegate {
    func didGetGetCatListData(data : JSON)
    func didFailGettingGetCatListDataWithError(error : String)
}

struct GetCatListDataManager {
    
    var delegate : GetCatListDataManagerDelegate?
    
    func getGetCatListData(key : String , parentId : String?){
        
        var urlString = ""
        
        if parentId == nil{
            urlString = "https://agrapi.tk-sad.ru/agr_cats.GetCatList?AKey=\(key)"
        }else{
            urlString = "https://agrapi.tk-sad.ru/agr_cats.GetCatListParent?AKey=\(key)&AParentID=\(parentId!)"
        }
        
        print("URLString for GetCatListDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingGetCatListDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingGetCatListDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetGetCatListData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
