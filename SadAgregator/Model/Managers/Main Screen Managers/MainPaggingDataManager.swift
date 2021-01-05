//
//  MainPaggingDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 29.11.2020.
//

import Foundation
import SwiftyJSON

protocol MainPaggingDataManagerDelegate {
    func didGetMainPaggingData(data : JSON)
    func didFailGettingMainPaggingDataWithError(error : String)
}

struct MainPaggingDataManager {
    
    var delegate : MainPaggingDataManagerDelegate?
    
    func getMainPaggingData(key : String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_intf.MainPaging?AKey=\(key)&APage=\(page)"
        
        print("URLString for MainPaggingDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {return}
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            if let safeData = try? Data(contentsOf: url) {
                
                let json = String(data: safeData , encoding: String.Encoding.windowsCP1251)!
                
                let jsonAnswer = JSON(parseJSON: json)
                
                delegate?.didGetMainPaggingData(data: jsonAnswer)
                
            }
            
        }
        
    }
    
}
