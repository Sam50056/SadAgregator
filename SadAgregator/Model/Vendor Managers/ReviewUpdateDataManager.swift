//
//  ReviewUpdateDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 15.12.2020.
//

import Foundation

struct ReviewUpdateDataManager {
    
    func getReviewUpdateData(key : String , vendId : String,  rating : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_intf.ReviewUpdate?AKey=\(key)&AvendID=\(vendId)&ARating=\(rating)&ATitle=&AText=&AImages="
        
        print("URLString for ReviewUpdateDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url)
        
        task.resume()
        
    }
    
}
