//
//  SetDefaultPeerDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 15.01.2021.
//

import Foundation
import SwiftyJSON

protocol SetDefaultPeerDataManagerDelegate {
    func didGetSetDefaultPeerData(data : JSON)
    func didFailGettingSetDefaultPeerDataWithError(error : String)
}

struct SetDefaultPeerDataManager {
    
    var delegate : SetDefaultPeerDataManagerDelegate?
    
    func getSetDefaultPeerData(key : String, peerId : String){
        
        let urlString = "http://agrapi.tk-sad.ru/agr_utils.SetDefaultPeer?AKey=\(key)&APeerID=\(peerId)"
        
        print("URLString for SetDefaultPeerDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingSetDefaultPeerDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingSetDefaultPeerDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingSetDefaultPeerDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetSetDefaultPeerData(data: jsonAnswer)
        }
        
        task.resume()
        
        
    }
    
}
