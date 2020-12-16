//
//  ReviewUpdateDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 15.12.2020.
//

import Foundation

struct ReviewUpdateDataManager {
    
    func getReviewUpdateData(key : String , vendId : String,  rating : Int, title : String = "" , text : String = ""){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_intf.ReviewUpdate?AKey=\(key)&AvendID=\(vendId)&ARating=\(rating)&ATitle=\(title)&AText=\(text)&AImages="
        
        print("URLString for ReviewUpdateDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url)
        
        task.resume()
        
    }
    
}
