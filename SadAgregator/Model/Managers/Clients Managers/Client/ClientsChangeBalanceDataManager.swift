//
//  ClientsChangeBalanceDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 22.03.2021.
//

import Foundation
import SwiftyJSON

protocol ClientsChangeBalanceDataManagerDelegate {
    func didGetClientsChangeBalanceData(data : JSON)
    func didFailGettingClientsChangeBalanceDataWithError(error : String)
}

struct ClientsChangeBalanceDataManager {
    
    var delegate : ClientsChangeBalanceDataManagerDelegate?
    
    func getClientsChangeBalanceData(key : String , clientId id : String , summ : Int , comment : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_clients.ChangeBalance?AKey=\(key)&AClientID=\(id)&ASumm=\(summ)&AComment=\(comment)"
        
        print("URLString for ClientsChangeBalanceDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingClientsChangeBalanceDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingClientsChangeBalanceDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetClientsChangeBalanceData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
