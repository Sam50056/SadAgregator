//
//  TopLinesDataManager .swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 05.01.2021.
//

import Foundation
import SwiftyJSON

protocol TopLinesDataManagerDelegate{
    func didGetTopLinesData(data : JSON)
    func didFailGettingTopLinesDataWithError(error : String)
}

struct TopLinesDataManager {
    
    var delegate : TopLinesDataManagerDelegate?
    
    func getTopLinesData(key : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_intf.TopLines?AKey=\(key)"
        
        print("URLString for TopLinesDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingTopLinesDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingTopLinesDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingTopLinesDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetTopLinesData(data: jsonAnswer)
            
        }
        
        task.resume()
        
        
    }
    
}
