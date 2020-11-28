//
//  GetSearchPageDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 27.11.2020.
//

import Foundation
import SwiftyJSON

protocol GetSearchPageDataManagerDelegate {
    func didGetSearchPageData(data : JSON)
    func didFailGettingSearchPageData(error : String)
}

struct GetSearchPageDataManager {
    
    var delegate : GetSearchPageDataManagerDelegate? 
    
    func getSearchPageData(key : String , query : String , page : Int) {
        
        let urlString = "https://agrapi.tk-sad.ru/agr_srch.GetSearchPage?AKey=\(key)&AQuery=\(query)&APage=\(page)"
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingSearchPageData(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingSearchPageData(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetSearchPageData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
