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
        
        print("URLString for GetSearchPageDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            if let safeData = try? Data(contentsOf: url) {
                
                let json = String(data: safeData , encoding: String.Encoding.windowsCP1251)!
                
                let jsonAnswer = JSON(parseJSON: json)
                
                delegate?.didGetSearchPageData(data: jsonAnswer)
                
            }
            
        }
        
    }
    
}
