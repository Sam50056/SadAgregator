//
//  NoAnswerDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 25.10.2021.
//

import Foundation
import SwiftyJSON

struct NoAnswerDataManager {
    
    func sendNoAnswerDataRequest(url : URL?){
        
        guard let url = url else {return}
        
        print("NoAnswerDataManager Request with URL : \(url)")
        
        URLSession(configuration: .default).dataTask(with: url).resume()
        
    }
    
}


